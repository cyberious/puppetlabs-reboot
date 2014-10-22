test_name "Windows Reboot Module - Custom Message"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
notify { 'step_1':
}
~>
reboot { 'now':
  when => refreshed,
  message => 'A different message',
}
MANIFEST

confine :to, :platform => 'windows'

windows_agents.each do |agent|
  step "Reboot Immediately with a Custom Message"

  #Apply the manifest.
  update_default_apply_opts_on(agent)
  apply_manifest_on(agent, reboot_manifest, apply_opts) do |result|
    assert_match /shutdown\.exe\s+\/r\s+\/t\s+60\s+\/d\s+p:4:1\s+\/c\s+\"A different message\"/,
      result.stdout, 'Expected reboot message is incorrect'
  end

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
