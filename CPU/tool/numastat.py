#-*- coding: utf-8 -*-
#!/usr/bin/env python
# numainfo - print all numa information 

import commands,os

f0 = 9
f1 = 19
n0 = 0
n1 = 0
n0_vm = 0
n1_vm = 0
with open('/sys/devices/system/cpu/online', 'r') as cl:
	cpus = cl.read().split('\n')[0].split('-')[-1]
	f0 = (int(cpus) + 1)/4 - 1
	f1 = (int(cpus) + 1)/2 - 1
el = commands.getoutput('uname -r')
ver=7
if 'el6' in el:
	ver = 6
elif 'el7' in el:
	ver = 7
	
def get_vmip(uuid):
	configpath = '/os_instance/%s/disk.config' % uuid
	try:
		if os.path.exists(configpath):
			with open(configpath,'rb') as tmp:
				buf = tmp.read().split('\n')
		for l in buf:
			if 'IPADDR' in l:
				ip = l.split('=')[1].split('>>')[0]
				break
			# 线上发现有的迁移后的虚机找不到注入文件，继续尝试查找
			if 'local-ipv4' in l:
				ip = l.split('"local-ipv4": "')[1].split('", "local-hostname"')[0]
				break
		for l in buf:
			if '\"name\": \"' in l and '\"}' in l:
				tmpl = l.split('availability_zone')[1].split('\"}')[0]
				tmpl = tmpl.split("\"name\": \"")[1]
				hostname = tmpl
				break
		return ip,hostname
	except Exception,e:
		print e

cmd='/usr/bin/numastat -c qemu-kvm'
outtext = commands.getoutput(cmd)
for line in outtext.split('\n'):
	if 'PID' in line:
		title=line
		print ('%-30s' % 'name') + ('%-20s' % 'ip') +('%-37s' % 'uuid') + ('%-12s' % 'node0_vcpus') + ('%-12s' % 'node1_vcpus') + ('%-10s' % 'node0_vms') + ('%-10s' % 'node1_vms') + title
	elif 'qemu-kvm' in line:
		sl=line.split()
		pid=sl[0]
		p='/proc/'+pid+'/cmdline'
		with open(p,'r') as f:
			for l in f:
				if ver == 6:
					name=l.split("-name")[1].split("-")[0]
				elif ver == 7:
					name=l.split('guest=')[1].split(',')[0]
				uuid=l.split("-uuid")[1][1:37]
				ip_name = get_vmip(uuid)
				c0s = commands.getoutput("virsh vcpupin " + str(uuid) + r" | grep '\-%s' | wc -l" % (f0))
				n0 += int(c0s)
				n0_has = 0
				n1_has = 0
				if int(c0s) > 0: 
					n0_vm += 1
					n0_has = 1
				c1s = commands.getoutput("virsh vcpupin " + str(uuid) + r" | grep '\-%s' | wc -l" % (f1))
				n1 += int(c1s)
				if int(c1s) > 0: 
					n1_vm += 1
					n1_has = 1
			print ('%-30s' % ip_name[1]) + ('%-20s' % ip_name[0]) + ('%-37s' % uuid) + ('%-12s' % c0s) + ('%-12s' % c1s) + ('%-10s' % n0_has) + ('%-10s' % n1_has) + line
	elif 'Total' in line:
		res = [float(line.split()[1]), float(line.split()[2])]
		ratio = max(res)/min(res)
		delta = max(res) - min(res)
		delta_vcpus = n0 - n1
		delta_vms = n0_vm - n1_vm
		pr = ''
		#if ratio <= 1.1:
		if delta <= 25000:
			pr = 'balance,' + str("%.2f" % ratio) + ',' + str(delta) + ',' + str(delta_vcpus) + ',' + str(delta_vms)
		else:
			pr = 'unbalance,' + str("%.2f" % ratio) + ',' + str(delta) + ',' + str(delta_vcpus) + ',' + str(delta_vms)
		print ('%-30s' % 'TOTAL') + ('%-20s' % '') + ('%-37s' % pr) + ('%-12s' % n0) + ('%-12s' % n1) + ('%-10s' % n0_vm) + ('%-10s' % n1_vm) + line
