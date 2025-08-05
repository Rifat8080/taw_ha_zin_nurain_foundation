class QrCodeService
  require 'rqrcode'
  require 'chunky_png'

  def initialize(data)
    @data = data
  end

  def generate_qr_code_png(size: 300)
    qr_code = RQRCode::QRCode.new(@data)
    
    # Create PNG from QR code
    png = qr_code.as_png(
      resize_gte_to: false,
      resize_exactly_to: size,
      fill: 'white',
      color: 'black',
      size: size,
      border_modules: 4,
      module_px_size: 6
    )
    
    png.to_s
  end

  def generate_qr_code_svg
    qr_code = RQRCode::QRCode.new(@data)
    qr_code.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 5,
      standalone: true
    )
  end

  def self.generate_for_ticket(ticket)
    service = new(ticket.qr_code_data)
    service.generate_qr_code_png
  end

  def self.generate_svg_for_ticket(ticket)
    service = new(ticket.qr_code_data)
    service.generate_qr_code_svg
  end
end
