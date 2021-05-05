Class PyPoc.UnitTest.mocking Extends %RegisteredObject
{

/// do ##class(PyPoc.UnitTest.mocking).PyTestGreeter()
ClassMethod PyTestGreeter() [ Language = python ]
{
    import iris, sys, unittest
    from unittest.mock import Mock, PropertyMock

    class TestGreeter(unittest.TestCase):
        """UnitTest for PyPoc.mocking.Greeter"""

        def setUp(self):
            """Setup test (instantiate objects)"""

            self.greeter = iris.cls("PyPoc.mocking.Greeter")._New()

            # create a mock TimeService that will be used by Greeter
            self.timeService = iris.cls("PyPoc.mocking.TimeService")._New()
            self.timeService = Mock(spec=['IsMorning', 'IsAfternoon', 'IsEvening'])
            self.greeter.timeService = self.timeService 
            
        def test_good_morning(self):
            """Mocked TimeService: IsMorning()=1"""

            self.timeService.IsMorning.return_value = 1
            self.assertEquals(self.greeter.GetSomeGreet("foo"), "Good morning foo!, have a nice day")
            self.assertEquals(self.timeService.IsMorning.call_count, 1, "Is Morning call count")

        def test_afternoon(self):
            """Mocked TimeService: IsAfternoon()=1"""
            
            self.timeService.IsMorning.return_value = 0
            self.timeService.IsAfternoon.return_value = 1
            self.assertEquals(self.greeter.GetSomeGreet("foo"), "Good afternoon foo")
            self.assertEquals(self.timeService.IsMorning.call_count, 1, "IsMorning call count")
            self.assertEquals(self.timeService.IsAfternoon.call_count, 1, "IsAfternoon call count")

    suite = unittest.TestLoader().loadTestsFromTestCase(TestGreeter)
    unittest.TextTestRunner(verbosity=1,stream=sys.stdout).run(suite)
}

}
