class DocumentsController < ApplicationController
  require 'securerandom'

  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :set_document_and_input, only: [:input_move_top, :input_move_up, :input_move_down, :input_move_bottom, :input_destroy]

  def index
    @documents = Document.all
  end

  def show
    output_tmp_name = "/tmp/#{SecureRandom.hex}.pdf"

    docs_to_glue = DocumentsHelper.create_tmp_files(@document.sorted_inputs)

    DocumentsHelper.create_output_file(docs_to_glue, output_tmp_name)

    @document.output.attach(io: File.open("#{output_tmp_name}"), filename: "#{@document.name}.pdf")
  end

    def new
    @document = Document.new
  end

  def edit
  end

  def create
    # TODO: convert image to pdf here

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
    # TODO: convert image to pdf here
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

  def input_move_top
    @input.move_to_top
    redirect_to edit_document_path(@document)
  end

  def input_move_down
    @input.move_lower
    redirect_to edit_document_path(@document)
  end
  
  def input_move_bottom
    @input.move_to_bottom
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
