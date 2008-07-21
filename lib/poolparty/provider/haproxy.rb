# Install haproxy
package :haproxy, :provides => :proxy do
  description 'Haproxy proxy'
  apt %w( haproxy )  
  
  verify do
    has_executable 'haproxy'
  end  
end