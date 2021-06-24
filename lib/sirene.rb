# frozen_string_literal: true

require 'smarter_csv'
require 'tempfile'
require 'zip'

require 'active_support/core_ext/string/inflections'

require 'sirene/configuration'
require 'sirene/data_gouv_server_error'
require 'sirene/http'
require 'sirene/insee_server_error'
require 'sirene/legal_unit'
require 'sirene/version'

class Sirene
  include Singleton

  def self.config
    Configuration.instance
  end

  def self.configure
    yield config
  end

  def self.legal_unit(siren)
    instance.legal_unit(siren)
  end

  def legal_unit(siren)
    LegalUnit.new(siren)
  end

  def self.legal_units(&block)
    instance.legal_units(&block)
  end

  def legal_units(&block)
    download_history('StockUniteLegale_utf8.zip') do |zip_io|
      extract_history(zip_io, 'StockUniteLegale_utf8.csv') do |csv_io|
        smarter_csv(csv_io, &block)
      end
    end
  end

  def self.establishment(siret)
    instance.establishment(siret)
  end

  def establishment(siret)
    Establishment.new(siret)
  end

  def self.establishments(&block)
    instance.establishments(&block)
  end

  def establishments(&block)
    download_history('StockEtablissement_utf8.zip') do |zip_io|
      extract_history(zip_io, 'StockEtablissement_utf8.csv') do |csv_io|
        smarter_csv(csv_io, &block)
      end
    end
  end

  def self.download_history(filename)
    instance.download_history(filename)
  end

  def download_history(filename)
    http = Net::HTTP.new('files.data.gouv.fr', 443)
    http.use_ssl = true

    response = http.get("/insee-sirene/#{filename}")
    response.body

    raise Sirene::DataGouvServerError, response unless response.is_a?(Net::HTTPSuccess)

    tmp_file = Tempfile.new(%w[data_gouv .zip])
    tmp_file.binmode
    tmp_file.write(response.body)
    tmp_file.flush
    tmp_file.rewind

    yield tmp_file
  end

  def self.extract_history(io, filename)
    instance.extract_history(io, filename)
  end

  def extract_history(io, filename)
    Zip::File.open(io) do |entries|
      csv_file = entries.find_entry(filename)

      return unless csv_file

      return yield csv_file.get_input_stream
    end
  end

  def self.smarter_csv(io, &block)
    instance.smarter_csv(io, &block)
  end

  def smarter_csv(io, &block)
    snake_case_transformer = ->(headers) { headers.map { |x| x.to_s.underscore.to_sym } }
    options = { header_transformations: [:none, snake_case_transformer] }

    if block_given?
      SmarterCSV.process(io, options) do |data|
        block.call(data.first)
      end
    else
      SmarterCSV.process(io, options)
    end
  end
end
