#https://puppet.com/blog/starting-out-writing-custom-facts-windows
Facter.add('domainnetbiosname') do
  confine :osfamily => :windows
  setcode do
    begin
      require 'win32ole'
      wmi = WIN32OLE.connect("winmgmts:\\\\.\\root\\cimv2")
      win32ntdomain = wmi.ExecQuery("SELECT * FROM Win32_NTDomain").each.first
      win32ntdomain.DomainName
    rescue
      nil
    end
  end
end
