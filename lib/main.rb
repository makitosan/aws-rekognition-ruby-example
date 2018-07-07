# frozen_string_literal: true

# Copyright (c) 2018 Akira. All rights reserved.
base_path = File.expand_path('..', File.dirname(__FILE__))
envfile_path = File.join(base_path, '.env')

File.foreach(envfile_path) do |line|
  key, value = line.split "="
  ENV[key] = value.strip
end

require 'aws-sdk-rekognition'
require 'rmagick'

@client = Aws::Rekognition::Client.new(region: ENV['AWS_REGION'],
                                       credentials: Aws::Credentials.new(ENV['AWS_KEY'], ENV['AWS_SECRET']))


# https://docs.aws.amazon.com/sdkforruby/api/Aws/Rekognition/Client.html#detect_faces-instance_method
img = "#{base_path}/img/GORI_SAYAIMG_4705_TP_V.jpg"
res = @client.detect_faces({
                               image: {
                                   bytes: File.read(img)
                               }
                           })
puts res.to_h
puts res.face_details.first.bounding_box.to_h

original = Magick::Image.read(img).first

gc = Magick::Draw.new

gc.fill_opacity(0)
gc.fill('transparent')
gc.stroke('red')
gc.stroke_width(3)

# Draw rectangle
ulx = original.columns * res.face_details.first.bounding_box.left
uly = original.rows * res.face_details.first.bounding_box.top
w = original.columns * res.face_details.first.bounding_box.width
h = original.rows * res.face_details.first.bounding_box.height

gc.rectangle(ulx, uly, ulx + w, uly + h)
gc.draw(original)

# new_image = original.blur_image(0.0, 10.0)
original.write("#{base_path}/tmp/result.jpg")


