public with sharing class CodeCheckController
{
	public List<SelectOption> allClasses { get; set; }
	public Id selectedClassId { get; set; }
	public ApexClass selectedClass { get; set; }

	public CodeCheckController()
	{
		this.allClasses = new List<SelectOption>{ new SelectOption('', '--None--') };
		this.selectedClass = new ApexClass();
		for( ApexClass aClass : [ SELECT Id, Name FROM ApexClass WHERE Status = 'Active' ORDER BY Name ASC] )
		{
			this.allClasses.add( new SelectOption( aClass.Id, aClass.Name ) );
		}
	}

	public void selectClass()
	{
		List<ApexClass> targetClass = [ SELECT Id, Body FROM ApexClass WHERE Id = :selectedClassId ];
		if( !targetClass.isEmpty() )
		{
			this.selectedClass = targetClass[0];
		}
	}
}