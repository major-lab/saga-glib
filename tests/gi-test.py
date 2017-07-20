import gi
gi.require_version('Saga', '1.0')
from gi.repository import Saga
import unittest

class GiTestCase(unittest.TestCase):
    def test_local_job_service(self):
        service_url = Saga.URL.new('local://')

        job_description = Saga.JobDescription(executable='true')

        job_service = Saga.JobService.new(Saga.Session(), service_url)

        job = job_service.create_job(job_description)

        job.run()
        self.assertEqual(0, job.get_result())
        self.assertEqual(Saga.TaskState.DONE, job.get_state())

unittest.main()

