test_name "Windows Reboot Module - Custom Timeout"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
notify { 'step_1':
}
~>
reboot { 'now':
  when => refreshed,
  timeout => 120,
}
MANIFEST

confine :to, :platform => 'windows'

windows_agents.each do |agent|
  step "Reboot Immediately with a Custom Timeout"

  #Apply the manifest.
  update_default_apply_opts_on(agent)
  apply_manifest_on(agent, reboot_manifest, apply_opts) do |result|
    assert_match /shutdown\.exe\s+\/r\s+\/t\s+120\s+\/d\s+p:4:1/,
                 result.stdout, 'Expected reboot timeout is incorrect'
  end

  #Waiting 61 seconds guarantees that the default timeout is different.
  sleep 61

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
