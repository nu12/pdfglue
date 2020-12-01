class DocumentsController < ApplicationController
  require 'securerandom'

  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :set_document_and_input, only: [:input_move_up, :input_move_down, :input_destroy]

  def index
    @documents = Document.all
  end

  def show
    # gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/default -dNOPAUSE -dQUIET -dBATCH -dDetectDuplicateImages -dCompressFonts=true -r150 -sOutputFile=output.pdf BanqueLaurentienne.pdf AlyssonCosta_fr.pdf
    docs_to_glue = ""
    output_tmp_name = "/tmp/#{SecureRandom.hex}.pdf"
    @document.sorted_inputs.each do | input | 
      File.open("/tmp/#{SecureRandom.hex}", 'wb') do |file|
        file.write(input.download)
        docs_to_glue += " #{File.expand_path(file)}"
      end 
    end
    p docs_to_glue
    %x(gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/default -dNOPAUSE -dQUIET -dBATCH -dDetectDuplicateImages -dCompressFonts=true -r150 -sOutputFile=#{output_tmp_name} #{docs_to_glue})

    @document.output.attach(io: File.open("#{output_tmp_name}"), filename: "#{@document.name}.pdf")
  end

    def new
    @document = Document.new
  end

  def edit
  end

  def create
    @document = Document.new(document_params)

    respond_to do |format|
      if @document.save
        format.html { redirect_to edit_document_path(@document), notice: 'Document was successfully created.' }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to edit_document_path(@document), notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @document.inputs.purge_later
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_url, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def input_move_up
    @input.move_higher
    redirect_to edit_document_path(@document)
  end

  def input_move_down
    @input.move_lower
    redirect_to edit_document_path(@document)
  end

  def input_destroy
    @input.purge
    redirect_to edit_document_path(@document)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    def set_document_and_input
      @document = Document.find(params[:document_id])
      @input = ActiveStorage::Attachment.find(params[:input_id])
    end

    # Only allow a list of trusted parameters through.
    def document_params
      params.require(:document).permit(:name, inputs: [])
    end
end
