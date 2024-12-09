Connect-VIServer escvc200.corp.pjc.com -User "CA_SSM_VMWare4@corp.pjc.com" -Password "d62$,JIQZej+"
Connect-VIServer ny5vc001.corp.pjc.com -User "CA_SSM_VMWare4@corp.pjc.com" -Password "d62$,JIQZej+"
Connect-VIServer escvc204.corp.pjc.com -User "CA_SSM_VMWare4@corp.pjc.com" -Password "d62$,JIQZej+"
Connect-VIServer ld4vc001.corp.pjc.com -User "CA_SSM_VMWare4@corp.pjc.com" -Password "d62$,JIQZej+"
Connect-VIServer escvc203.corp.pjc.com -User "CA_SSM_VMWare4@corp.pjc.com" -Password "d62$,JIQZej+"
Connect-VIServer ny5vc002.corp.pjc.com  -User "CA_SSM_VMWare4@corp.pjc.com" -Password "d62$,JIQZej+"

Disconnect-VIServer -Server * -Confirm:$false

#test