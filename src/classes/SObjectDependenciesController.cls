public class SObjectDependenciesController
{
	public List<SelectOption> sObjectNames { get; set; }
	public String selectedSObjectName { get; set; }

	public String generatedText { get; set; }

	public SObjectDependenciesController()
	{
		sObjectNames = new List<SelectOption>();
		sObjectNames.add( new SelectOption( '', '-- Select an SObject --' ) );

		Map<String, Schema.SObjectType> sObjectsDescribe = Schema.getGlobalDescribe();
		List<String> namesList = new List<String>();
		for( String sObjectName : sObjectsDescribe.keySet() )
		{
			Schema.DescribeSObjectResult objectResult = sObjectsDescribe.get( sObjectName ).getDescribe();
			if( objectResult.isCreateable() && objectResult.isUpdateable() )
			{
				namesList.add( sObjectName );
			}
		}
		namesList.sort();

		for( String sObjectName : namesList )
		{
			sObjectNames.add( new SelectOption( sObjectName, sObjectsDescribe.get( sObjectName ).getDescribe().getName() ) );
		}
	}

	public void getSObjectFields()
	{
		generatedText = '';

		if( selectedSObjectName != null && selectedSObjectName != '' )
		{
			Map<String, Schema.SObjectType> sObjectsDescribe = Schema.getGlobalDescribe();

			Schema.SObjectType selectedSObject = sObjectsDescribe.get( selectedSObjectName );
			Schema.DescribeSObjectResult sObjectResult = selectedSObject.getDescribe();

			generatedText += SObjectDescribeServices.generateTestUtilBlock( sObjectResult );

			generatedText += '\n' + SObjectDescribeServices.getParentObjects( sObjectResult );
		}
	}
}