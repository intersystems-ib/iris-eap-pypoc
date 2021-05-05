Class PyPoc.UnitTest.mocking Extends %RegisteredObject
{

/// do ##class(PyPoc.UnitTest.mocking).PyTestGreeter()
ClassMethod PyTestGreeter() [ Language = python ]
{
    import iris, sys, unittest
    from unittest.mock import Mock, PropertyMock

    class TestGreeter(unittest.TestCase):
        
        def setUp(self):
            self.greeter = iris.cls("PyPoc.mocking.Greeter")._New()
            self.timeService = iris.cls("PyPoc.mocking.TimeService")._New()
            self.timeService = Mock(spec=['IsMorning', 'IsAfternoon', 'IsEvening'])
            self.greeter.timeService = self.timeService 
            
        def test_good_morning(self):
            self.timeService.IsMorning.return_value = 1
            self.assertEquals(self.greeter.GetSomeGreet("foo"), "Good morning foo!, have a nice day")
            self.assertEquals(self.timeService.IsMorning.call_count, 1, "Is Morning call count")

        def test_afternoon(self):
            self.timeService.IsMorning.return_value = 0
            self.timeService.IsAfternoon.return_value = 1
            self.assertEquals(self.greeter.GetSomeGreet("foo"), "Good afternoon foo")


    suite = unittest.TestLoader().loadTestsFromTestCase(TestGreeter)
    unittest.TextTestRunner(verbosity=1,stream=sys.stdout).run(suite)
}

}
