Class PyPoc.UnitTest.mocking Extends %RegisteredObject
{

/// do ##class(PyPoc.UnitTest.mocking).PyTestSimple()
ClassMethod PyTestSimple() [ Language = python ]
{
    import iris, sys, unittest
    from unittest.mock import Mock, PropertyMock

    class TestSimple(unittest.TestCase):
        def test_populate_utils(self):
            
            # let's say we need to mock %Library.PopulateUtils behaviour
            popUtils = iris.cls("%Library.PopulateUtils")
            popUtils = Mock()
            popUtils.Name.return_value = "Mocked Name"
            
            someName = popUtils.Name()
            popUtils.Name.assert_called()
            self.assertEquals(someName, "Mocked Name")
            

    suite = unittest.TestLoader().loadTestsFromTestCase(TestSimple)
    unittest.TextTestRunner(verbosity=1,stream=sys.stdout).run(suite)
}

/// do ##class(PyPoc.UnitTest.mocking).PyTestRestData()
ClassMethod PyTestRestData() [ Language = python ]
{
    import sys
    import requests
    import unittest
    from unittest.mock import Mock

    # Mock requests to control its behavior
    requests = Mock()

    def get_rest_data():
        r = requests.get('http://localhost/api/restdata')
        if r.status_code == 200:
            return r.json()
        return None

    class TestRestData(unittest.TestCase):
        def log_request(self, url):
            # Log a fake request for test output purposes
            print(f'Making a request to {url}.')
            print('Request received!')

            # Create a new Mock to imitate a Response
            response_mock = Mock()
            response_mock.status_code = 200
            response_mock.json.return_value = {
                'Name': 'Some name',
                'Alias': 'awesome123',
            }
            return response_mock

        def test_get_rest_data_logging(self):
            # Test a successful, logged request
            requests.get.side_effect = self.log_request
            assert get_rest_data()['Name'] == 'Some name'
            

    suite = unittest.TestLoader().loadTestsFromTestCase(TestRestData)
    unittest.TextTestRunner(verbosity=1,stream=sys.stdout).run(suite)
}

}
