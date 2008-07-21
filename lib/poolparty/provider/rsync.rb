package :rsync do
  description "Rsync"
  apt %w( rsync )
  
  verify do
    has_executable 'rsync'
  end
end