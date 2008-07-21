package :git do
  description "Git SCM"
  apt %w( zlib1g-dev git-core )
  
  verify do
    has_executable 'git'
  end
end