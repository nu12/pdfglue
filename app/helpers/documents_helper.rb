module DocumentsHelper

    def self.create_tmp_files(inputs)
        docs_to_glue = ""

        inputs.each do | input | 
            tmp_name = "/tmp/#{SecureRandom.hex}"
            File.open(tmp_name, 'wb') do |file|
                file.write(input.download)

                docs_to_glue += " #{tmp_name}"
        
                if (input.filename.to_s.split('.')[1] != "pdf")
                    DocumentsHelper.convert_to_pdf(tmp_name)
                    docs_to_glue += ".pdf" # Add .pdf to filename in case it was converted
                end
            end 
        end

        return docs_to_glue
    end

    def self.create_output_file(input_string, output_string)
        %x(gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/default -dNOPAUSE -dQUIET -dBATCH -dDetectDuplicateImages -dCompressFonts=true -r150 -sOutputFile=#{output_string} #{input_string})
    end

    def self.convert_to_pdf(filename)
        %x(convert #{filename} #{filename}.pdf)
    end
end
