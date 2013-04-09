public class SObjectDescribeServices
{
	public static String generateTestUtilBlock( Schema.DescribeSObjectResult sObjectDescribe )
	{
		String generatedCode = '';
		String objectName = sObjectDescribe.getName();
		Set<String> requiredFieldNames = new Set<String>();

		// get field map for sobject describe
		Map<String, Schema.SObjectField> fieldMap = sObjectDescribe.fields.getMap();
		// look through all fields, and gather required fields
		for( String fieldName : fieldMap.keySet() )
		{
			Schema.DescribeFieldResult fieldDescribe = fieldMap.get( fieldName ).getDescribe();
			if( fieldIsRequired( fieldDescribe ) )
			{
				requiredFieldNames.add( fieldName );
			}
		}

		String methodSignature = '';
		for( String requiredField : requiredFieldNames )
		{
			methodSignature += fieldMap.get( requiredField ).getDescribe().getSOAPType();
			methodSignature += ' ' + requiredField;
			methodSignature += ', ';
		}

		List<String> signatureParams = new List<String>();
		signatureParams.add( objectName );
		signatureParams.add( sObjectDescribe.getLabelPlural().replace( ' ', '' ) );
		signatureParams.add( methodSignature );

		generatedCode += String.format( 'public List<{0}> create{1}( Integer numOfRecords, {2}Boolean doInsert )', signatureParams );
		generatedCode += '\n{';
		generatedCode += String.format( '\n\tList<{0}> newObjects = new List<{0}>();', new List<String>{ objectName } );
		generatedCode += '\n\tfor( Integer index = 0; index < numOfRecords; index++ )';
		generatedCode += '\n\t{';
		generatedCode += String.format( '\n\t\t{0} newRecord = new {0}();', new List<String>{ objectName } );

		for( String requiredField : requiredFieldNames )
		{
			generatedCode += String.format( '\n\t\tnewRecord.{0} = {0};', new List<String>{ requiredField } );
		}

		generatedCode += '\n\t\tnewObjects.add( newRecord );';
		generatedCode += '\n\t}';
		generatedCode += '\n\n\tif( doInsert )';
		generatedCode += '\n\t{';
		generatedCode += '\n\t\tinsert newObjects';
		generatedCode += '\n\t}';
		generatedCode += '\n\n\treturn newObjects';
		generatedCode += '\n}';

		return generatedCode;
	}

	public static String getParentObjects( Schema.DescribeSObjectResult sObjectDescribe )
	{
		String parentCode = '';
		String objectName = sObjectDescribe.getName();

		// get field map for sobject describe
		Map<String, Schema.SObjectField> fieldMap = sObjectDescribe.fields.getMap();
		// look through all fields, and gather lookups
		for( String fieldName : fieldMap.keySet() )
		{
			Schema.DescribeFieldResult fieldDescribe = fieldMap.get( fieldName ).getDescribe();
			if( fieldIsRequired( fieldDescribe ) && !fieldDescribe.getReferenceTo().isEmpty() )
			{
				for( Schema.SObjectType parentSObject : fieldDescribe.getReferenceTo() )
				{
					parentCode += generateTestUtilBlock( parentSObject.getDescribe() );
					parentCode += '\n';
				}
			}
		}

		return parentCode;
	}

	public static Boolean fieldIsRequired( Schema.DescribeFieldResult fieldResult )
	{
		return fieldResult.isCreateable() && !fieldResult.isNillable() && !fieldResult.isDefaultedOnCreate();
	}
}