class DocumentsController < ApplicationController
  require 'securerandom'

  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :set_document_and_input, only: [:input_move_top, :input_move_up, :input_move_down, :input_move_bottom, :input_destroy]
  after_action :convert, only: [:create, :update, :input_move_top, :input_move_up, :input_move_down, :input_move_bottom, :input_destroy]

  def index
    @documents = Document.all
  end

  def new
    @document = Document.new
  end

  def edit
  end

  def create
    @document = Document.new(document_params)
    
    if @document.save
      redirect_to edit_document_path(@document), notice: 'Document was successfully created.'
    else
      render :new 
    end
  end

  def update
    if @document.update(document_params)
      redirect_to edit_document_path(@document), notice: 'Document was successfully updated.' 
    else
      render :edit 
    end
  end

  def destroy
    @document.inputs.purge_later
    @document.destroy

    redirect_to documents_url, notice: 'Document was successfully destroyed.'
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

    def convert
      output_tmp_name = "/tmp/#{SecureRandom.hex}.pdf"

      docs_to_glue = DocumentsHelper.create_tmp_files(@document.sorted_inputs)
  
      DocumentsHelper.create_output_file(docs_to_glue, output_tmp_name)
  
      @document.output.attach(io: File.open("#{output_tmp_name}"), filename: "#{@document.name}.pdf")
    end
end
