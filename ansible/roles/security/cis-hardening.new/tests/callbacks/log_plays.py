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

import os
import time
import json
import hashlib
import re

ROLE_PATH = 'roles/cis'
ROLE_PATH = '.'

class TestBook(object):
    def __init__(self):
        self.tasks = {}

    def new(self, name):
        n = name.split('|')[1]
        self.tasks[n] = TestTask(n)
        return self.update(name.split('|')[1], 'FAIL')

    def update(self, name, status):
        self.tasks[name].update(status)
        return self.tasks[name]

    def jsonify(self):
        d = {}
        d['service_job_id'] = os.environ['TRAVIS_JOB_ID']
        d['service_name'] = "travis-ci"
        d['source_files'] = []

        s = {}
        for i in self.tasks:
            # Notifies
            if self.tasks[i].section == None:
                continue

            t = self.tasks[i]

            if t.sublevel != None:
                with open("%s/tasks/section_%s_level%s_%s.yml" % (ROLE_PATH, t.section, t.level, t.subsection)) as f:
                    data = f.read()
                tname = "tasks/section_%s_level%s_%s.yml" % (t.section, t.level, t.subsection)
            else:
                with open("%s/tasks/section_%s_level%s.yml" % (ROLE_PATH, t.section, t.level)) as f:
                    data = f.read()
                tname = "tasks/section_%s_level%s.yml" % (t.section, t.level)

            if not tname in s:
                s[tname] = {}
                s[tname]["name"] = tname 
                s[tname]["source_digest"] = hashlib.md5(data).hexdigest()
                s[tname]["coverage"] = [0] * len(data.split('\n'))

            for n in range(t.line_start, t.line_start + t.line_size + 1):
                s[tname]["coverage"][n] = t.isalwaysok or int(t.status == 'CHANGED')

            n = 0
            for line in data.splitlines():
                match = re.match(r'\s*(---|tags:|- section.*|- (include|name): .*)?$', line)
                if match:
                    s[tname]["coverage"][n] = None
                n += 1

        for se in s:
            d['source_files'].append(s[se])

        return json.dumps(d)

class TestTask(object):
    def __init__(self, name):
        self.name = name
        self.status = 'null'
        self.level = None
        self.sublevel = None
        try:
            self.section = "%02d" % int(self.name.split('.')[0])
        # Notifies are executed
        except ValueError:
            self.section = None

        try:
            self.subsection = "%02d" % int(self.name.split('.')[1])
        # Notifies are executed
        except:
            self.subsection = None

        if self.section != None:
            try:
                with open("%s/tasks/section_%s_level1_%s.yml" % (ROLE_PATH, self.section, self.subsection)) as f:
                    data = f.readlines()
                num = data.index([ n for n in data if self.name in n ][0])
                self.level = 1
                self.sublevel = self.subsection
            except:
                try:
                    with open("%s/tasks/section_%s_level1.yml" % (ROLE_PATH, self.section)) as f:
                        data = f.readlines()
                    num = data.index([ n for n in data if self.name in n ][0])
                    self.level = 1
                except:
                    with open("%s/tasks/section_%s_level2.yml" % (ROLE_PATH, self.section)) as f:
                        data = f.readlines()
                    num = data.index([ n for n in data if self.name in n ][0])
                    self.level = 2

            self.line_start = num
            while num<len(data)-1 and data[num] != '\n':
                num+= 1
            self.line_size = num - self.line_start
            teststat = int(data[self.line_start+1].split(':')[0].strip() == 'stat')
            for n in range(self.line_start, self.line_start + self.line_size + 1):
                if 'changed_when: False' in data[n]:
                    teststat = 1
                if 'debug:' in data[n]:
                    teststat = 1
            self.isalwaysok = teststat

    def update(self, status):
        # We cannot go back to OK after CHANGED
        if not (self.status == 'CHANGED' and status == 'OK'):
            self.status = status

class CallbackModule(object):
    """
    """
    def __init__(self):
        self.book = TestBook()
        self.current_task = TestTask('12.2')

    def on_any(self, *args, **kwargs):
        pass

    def runner_on_failed(self, host, res, ignore_errors=False):
        self.current_task.update('FAIL')

    def runner_on_ok(self, host, res):
        #m = json.loads(res)
        s = 'OK'
        if 'changed' in res and res['changed'] == True:
            s = 'CHANGED'
        self.current_task.update(s)

    def runner_on_skipped(self, host, item=None):
        self.current_task.update('SKIPPED')

    def runner_on_unreachable(self, host, res):
        self.current_task.update('UNREACHABLE')

    def runner_on_no_hosts(self):
        pass

    def runner_on_async_poll(self, host, res, jid, clock):
        pass

    def runner_on_async_ok(self, host, res, jid):
        pass

    def runner_on_async_failed(self, host, res, jid):
        pass

    def playbook_on_start(self):
        print('Starting with test callback')

    def playbook_on_notify(self, host, handler):
        pass

    def playbook_on_no_hosts_matched(self):
        pass

    def playbook_on_no_hosts_remaining(self):
        pass

    def playbook_on_task_start(self, name, is_conditional):
        self.current_task = self.book.new(name)

    def playbook_on_vars_prompt(self, varname, private=True, prompt=None, encrypt=None, confirm=False, salt_size=None, salt=None, default=None):
        pass

    def playbook_on_setup(self):
        pass

    def playbook_on_import_for_host(self, host, imported_file):
        pass

    def playbook_on_not_import_for_host(self, host, missing_file):
        pass

    def playbook_on_play_start(self, name):
        pass

    def playbook_on_stats(self, stats):
        print("playbook_on_stats ok")
        with open("/tmp/coveralls", "w") as f:
            f.write(self.book.jsonify())
        print(os.listdir("/tmp/"))
