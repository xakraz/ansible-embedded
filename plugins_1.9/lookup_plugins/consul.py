# (c) 2014, Xavier Krantz <xakraz(at)gmail.com>
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.


from ansible import utils
import os
import urllib2
import base64
try:
    import json
except ImportError:
    import simplejson as json


# This can be made configurable, 
# We should not use 'ansible.cfg'
ANSIBLE_CONSUL_URL = 'http://127.0.0.1:8500'
if os.getenv('ANSIBLE_CONSUL_URL') is not None:
    ANSIBLE_CONSUL_URL = os.environ['ANSIBLE_CONSUL_URL']

class consul():
    def __init__(self, url=ANSIBLE_CONSUL_URL):
        self.url = url
        self.baseurl = '%s/v1/kv' % (self.url)

    def get(self, key):
        url = "%s/%s" % (self.baseurl, key)

        data = None
        #value = "ANSIBLE_LOOKUP_FAILED"
        value = ""
        try:
            r = urllib2.urlopen(url)
            data = r.read()
        except:
            return value

        try:
          # [
          #   {
          #     "CreateIndex": 182, 
          #     "Flags": 0, 
          #     "Key":"/name", 
          #     "LockIndex": 0, 
          #     "ModifyIndex": 182, 
          #     "Value":"BASE64 ENCODED"
          #   }
          # ]
            item = json.loads(data)
            if 'Value' in item[0]:
                encodedValue = item[0]['Value']
                value = base64.b64decode(encodedValue)
            if 'errorCode' in item:
                value = "ENOENT"
        except:
            raise
            pass

        return value

class LookupModule(object):

    def __init__(self, basedir=None, **kwargs):
        self.basedir = basedir
        self.consul = consul()

    def run(self, terms, inject=None, **kwargs):

        terms = utils.listify_lookup_plugin_terms(terms, self.basedir, inject)

        if isinstance(terms, basestring):
            terms = [ terms ]

        ret = []
        for term in terms:
            key = term.split()[0]
            value = self.consul.get(key)
            ret.append(value)
        return ret
