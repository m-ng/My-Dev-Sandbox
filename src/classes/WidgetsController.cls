public class WidgetsController
{
	public Component.Apex.OutputPanel getAllComponentsPanel()
	{
		return new Component.Apex.OutputPanel();
	}

	public List<KnowledgeArticleVersion> articles { get; set; }

	public WidgetsController()
	{
		this.articles = [ SELECT Id FROM KnowledgeArticleVersion WHERE IsLatestVersion = TRUE AND PublishStatus = 'Online' AND Language = 'en_US' ];
	}
}