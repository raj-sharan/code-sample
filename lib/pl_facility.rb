
class PlFacility

  EKART = "EKART"
  THIRDPARTYLOGISTICS = "THIRDPARTYLOGISTICS"

  RETURN = "RETURN"
  FORWARD = "FORWARD"

  def initialize(shipment_params)
    @shipment_params = shipment_params
  end

  def facility
    logger.info "Calling ProcLogistics new API with payload: #{payload}"
    final_response = nil
    begin
      facility_response = Pkl::Client::PlClient.get_facility_by_seller_and_pincode(payload)
      if facility_response.present?
        logger.info "ProcLogistics responded with: #{facility_response.assignments.inspect}"
        final_response = facility_response.assignments.first[:motherHub]
      else
        logger.error "Got no response from ProcLogistic for #{payload}"
      end
    rescue Exception => ex
      logger.error "Exception in Proc logistics request : #{ex}"
    end
    final_response
  end

  def payload
    {
        "detailsList" => [
            {
                "shipmentSize"       => @shipment_params[:size],
                "merchantId"         => @shipment_params[:merchant_code],
                "customerPostalCode" => @shipment_params[:customer_postal_code],
                "sellerPostalCode"   => @shipment_params[:seller_postal_code],
                "vendorType"         => vendor_type,
                "sellerId"           => @shipment_params[:seller_id],
                "serviceType"        => service_type
            }
        ]
    }
  end

  def vendor_type
    if [12,38].include?(@shipment_params[:vendor_id].to_i)
      EKART
    else
      THIRDPARTYLOGISTICS
    end
  end

  def service_type
    if @shipment_params[:is_rvp]
      RETURN
    else
      FORWARD
    end
  end

end
