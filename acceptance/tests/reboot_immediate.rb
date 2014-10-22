test_name "Windows Reboot Module - Reboot Immediately"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
notify { 'step_1':
}
~>
reboot { 'now':
}
MANIFEST

confine :to, :platform => 'windows'

windows_agents.each do |agent|
  step "Reboot Immediately with Refresh"

  #Apply the manifest.
  apply_manifest_on(agent, reboot_manifest, apply_opts)

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
