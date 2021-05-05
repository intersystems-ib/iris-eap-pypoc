Class PyPoc.mocking.Greeter Extends %RegisteredObject
{

Property timeService As TimeService;

Method GetSomeGreet(name As %String) As %String
{
    if ..timeService.IsMorning() {
        quit "Good morning "_name_"!, have a nice day"
    }
    elseif ..timeService.IsAfternoon() {
        quit "Good afternoon "_name
    }
    quit "Good evening "_name
}

}
