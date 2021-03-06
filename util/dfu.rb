# capture.rb
# Tells the Timelapse+ to have the camera take a picture
#
# Usage:
#
# ruby ./capture.rb
#
#
# By Elijah Parker
# mail@timelapseplus.com
#
# For Mac OS X only



require 'serialport'


class TLP
	def open(port)
		port_str = port
		baud_rate = 9600
		data_bits = 8
		stop_bits = 1
		parity = SerialPort::NONE
		@sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
		@sp.read_timeout=1000
	end

	def id
		@sp.putc('T')
		@sp.getc
	end

	def dfu
		@sp.putc('$')
	end

	def screen
		scr = Array.new()
		@sp.putc('S')
		504.times do
			scr.push(@sp.getbyte)
		end
		return scr
	end

	def close
		@sp.close if(@sp)
	end

	def find
		result = false
		[1..10].each do
			list = `ls /dev/tty.usb*`
			sid = "E"
			list.split("\n").each do |dev|
				dev.strip!
				begin
					puts "Trying '" + dev + "'..."
					open(dev)
					tid = id
					result = true if tid == sid
					break
					puts "Invalid ID (" + tid + ") - expected " + sid + ".\n"
					close
				rescue
					puts "Error opening.\n"
					close
					result = false
				end
			end
		end
		return result
	end
end

device = TLP.new
if(device.find)
	device.dfu
end

device.close


