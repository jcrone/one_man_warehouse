class AmazonClient
    attr_reader :client
    require 'csv'
    require 'tempfile'

    def initialize
        amazon_reports = AmzSpApi::ReportsApiModel::ReportsApi.new(AmzSpApi::SpApiClient.new)
        opts = { 
            report_types: ['GET_MERCHANT_LISTINGS_DATA'], # Array<String> | A list of report types used to filter reports. When reportTypes is provided, the other filter parameters (processingStatuses, marketplaceIds, createdSince, createdUntil) and pageSize may also be provided. Either reportTypes or nextToken is required.
        }
  
        begin
            result = amazon_reports.get_reports(opts)
        rescue AmzSpApi::ReportsApiModel::ApiError => e
            puts "Exception when calling ReportsApi->get_reports: #{e}"
        end
        report_document_id = result.reports.first[:reportDocumentId] 

        api_instance = AmzSpApi::ReportsApiModel::ReportsApi.new(AmzSpApi::SpApiClient.new)

        begin
            @result = api_instance.get_report_document(report_document_id)
          rescue AmzSpApi::ReportsApiModel::ApiError => e
            puts "Exception when calling ReportsApi->get_report_document: #{e}"
        end

    end

    def add_skus(inventory)
    #   syncing = Sync.find(1)
    #   syncing.pending!
      @inventory = inventory
      
      content = Faraday.get(@result.url).body

      temp_report = Tempfile.new("report_temp.csv")
      temp_report << content
      temp_report.write(content)
      temp_report.rewind

      amz_report = CSV.read(temp_report.path,col_sep: "\t", headers: true, quote_char: nil)

      @inventory.each do |inventory| 
          item = amz_report.find {|row| row['asin1'] == inventory.asin}
          if item.nil?
              inventory.active = "NOT-ACTIVE"
              inventory.save
          else 
              inventory.sku = item["seller-sku"]
              inventory.active = "ACTIVE"
              inventory.save
          end
      end 
    #   syncing.completed!  
    end 

end