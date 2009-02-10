=begin rdoc
  Base provisioner capistrano tasks
=end
Capistrano::Configuration.instance(:must_exist).load do
  # namespace(:base) do
#
    task :ls do
      run "ls"
    end

  task :ls_g do
    capture "VBoxManage list vms"
  end
end
