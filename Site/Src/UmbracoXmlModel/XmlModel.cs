using System;

namespace UmbracoXmlModel
{
    public partial class XmlTypeMapping
    {
        [UmbracoXmlMappingMethodAttribute()]
        private void LoadTypeList()
        {
            _mapping.Add("BuyLanding", typeof(BuyLanding));
            _mapping.Add("Donate", typeof(Donate));
            _mapping.Add("DonateDetail", typeof(DonateDetail));
            _mapping.Add("DonateType", typeof(DonateType));
            _mapping.Add("DonwloadHandler", typeof(DonwloadHandler));
            _mapping.Add("DownloadMirror", typeof(DownloadMirror));
            _mapping.Add("DownloadPage", typeof(DownloadPage));
            _mapping.Add("FeedBack", typeof(FeedBack));
            _mapping.Add("Form", typeof(Form));
            _mapping.Add("FreeActivationHandler", typeof(FreeActivationHandler));
            _mapping.Add("FreeFullActivationForm", typeof(FreeFullActivationForm));
            _mapping.Add("GoogleSiteMap", typeof(GoogleSiteMap));
            _mapping.Add("HomePage", typeof(HomePage));
            _mapping.Add("HomePageImage", typeof(HomePageImage));
            _mapping.Add("LanguageHolder", typeof(LanguageHolder));
            _mapping.Add("Master", typeof(Master));
            _mapping.Add("NewsItem", typeof(NewsItem));
            _mapping.Add("NewsLanding", typeof(NewsLanding));
            _mapping.Add("Redirect301", typeof(Redirect301));
            _mapping.Add("Release", typeof(Release));
            _mapping.Add("ReleasesHolder", typeof(ReleasesHolder));
            _mapping.Add("Settings", typeof(Settings));
            _mapping.Add("SettingsHomePage", typeof(SettingsHomePage));
            _mapping.Add("SimplePage", typeof(SimplePage));
            _mapping.Add("SiteSettings", typeof(SiteSettings));
            _mapping.Add("SiteSettingsLanguage", typeof(SiteSettingsLanguage));
            _mapping.Add("UnInstallReason", typeof(UnInstallReason));
            _mapping.Add("VersionLog", typeof(VersionLog));
            _mapping.Add("XmlUpdateCheck", typeof(XmlUpdateCheck));
        }
    }
    public partial class MediaXmlTypeMapping
    {
        [UmbracoXmlMappingMethodAttribute()]
        private void LoadTypeList()
        {
            _mapping.Add("File", typeof(MediaFile));
            _mapping.Add("Folder", typeof(MediaFolder));
            _mapping.Add("Image", typeof(MediaImage));
            _mapping.Add("Release", typeof(MediaRelease));
            _mapping.Add("ReleaseFolder", typeof(MediaReleaseFolder));
            _mapping.Add("ReleaseHolder", typeof(MediaReleaseHolder));
        }
    }
    [UmbracoXmlAttribute("BuyLanding")]
    public class BuyLanding : Master
    {
        public BuyLanding(string xPath) : base(xPath) { }
        public BuyLanding(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("Donate")]
    public class Donate : Master
    {
        [UmbracoXmlAttribute("textDonate")]
        public string Donatetext { get; set; }
        [UmbracoXmlAttribute("donateCommonInfo")]
        public string DonateCommonInfo { get; set; }
        [UmbracoXmlAttribute("donateMoneyCaption")]
        public string DonateMoneyCaption { get; set; }
        [UmbracoXmlAttribute("donateMoneyText")]
        public string DonateMoneyText { get; set; }
        [UmbracoXmlAttribute("donateMoneyInfo")]
        public string DonateMoneyinfo { get; set; }
        [UmbracoXmlAttribute("thankYouText")]
        public string ThankYouText { get; set; }
        [UmbracoXmlAttribute("donateInfoCaption")]
        public string DonateInfoCaption { get; set; }
        [UmbracoXmlAttribute("donateInfoText")]
        public string DonateInfoText { get; set; }
        public Donate(string xPath) : base(xPath) { }
        public Donate(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("DonateDetail")]
    public class DonateDetail : UmbracoXmlEntry
    {
        [UmbracoXmlAttribute("detailText")]
        public string Detailtext { get; set; }
        [UmbracoXmlAttribute("fontSize")]
        public Int32? FontSize { get; set; }
        public DonateDetail(string xPath) : base(xPath) { }
        public DonateDetail(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("DonateType")]
    public class DonateType : UmbracoXmlEntry
    {
        [UmbracoXmlAttribute("name")]
        public string Name { get; set; }
        [UmbracoXmlAttribute("donateImage")]
        public Int32? Donateimage { get; set; }
        [UmbracoXmlAttribute("paddingTop")]
        public Int32? PaddingTop { get; set; }
        public DonateType(string xPath) : base(xPath) { }
        public DonateType(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("DonwloadHandler")]
    public class DonwloadHandler : UmbracoXmlEntry
    {
        public DonwloadHandler(string xPath) : base(xPath) { }
        public DonwloadHandler(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("DownloadMirror")]
    public class DownloadMirror : UmbracoXmlEntry
    {
        [UmbracoXmlAttribute("urlName")]
        public string Urlname { get; set; }
        [UmbracoXmlAttribute("urlLocation")]
        public string Urllocation { get; set; }
        [UmbracoXmlAttribute("weight")]
        public Int32? Weight { get; set; }
        public DownloadMirror(string xPath) : base(xPath) { }
        public DownloadMirror(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("DownloadPage")]
    public class DownloadPage : Master
    {
        [UmbracoXmlAttribute("downloadStableText")]
        public string DownloadStableText { get; set; }
        [UmbracoXmlAttribute("downloadNotStableText")]
        public string DownloadNotStableText { get; set; }
        [UmbracoXmlAttribute("listOfAllReleasesText")]
        public string ListOfAllReleasesText { get; set; }
        [UmbracoXmlAttribute("downloadStableLabelText")]
        public string DownloadStableLabelText { get; set; }
        [UmbracoXmlAttribute("downloadNotStableLabelText")]
        public string DownloadNotStableLabelText { get; set; }
        public DownloadPage(string xPath) : base(xPath) { }
        public DownloadPage(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("FeedBack")]
    public class FeedBack : Master
    {
        [UmbracoXmlAttribute("firstNameText")]
        public string FirstNameText { get; set; }
        [UmbracoXmlAttribute("lastNameText")]
        public string LastNameText { get; set; }
        [UmbracoXmlAttribute("emailText")]
        public string EmailText { get; set; }
        [UmbracoXmlAttribute("organizationText")]
        public string OrganizationText { get; set; }
        [UmbracoXmlAttribute("themeText")]
        public string ThemeText { get; set; }
        [UmbracoXmlAttribute("messageText")]
        public string MessageText { get; set; }
        [UmbracoXmlAttribute("submitText")]
        public string SubmitText { get; set; }
        [UmbracoXmlAttribute("requiredText")]
        public string RequiredText { get; set; }
        [UmbracoXmlAttribute("invalidFormatText")]
        public string InvalidFormatText { get; set; }
        [UmbracoXmlAttribute("thankYouMessage")]
        public string ThankYouMessage { get; set; }
        public FeedBack(string xPath) : base(xPath) { }
        public FeedBack(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("Form")]
    public class Form : Master
    {
        [UmbracoXmlAttribute("thankYouMessage")]
        public string ThankYouMessage { get; set; }
        [UmbracoXmlAttribute("submitText")]
        public string SubmitText { get; set; }
        [UmbracoXmlAttribute("requiredText")]
        public string RequiredText { get; set; }
        [UmbracoXmlAttribute("invalidFormatText")]
        public string InvalidFormatText { get; set; }
        public Form(string xPath) : base(xPath) { }
        public Form(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("FreeActivationHandler")]
    public class FreeActivationHandler : UmbracoXmlEntry
    {
        public FreeActivationHandler(string xPath) : base(xPath) { }
        public FreeActivationHandler(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("FreeFullActivationForm")]
    public class FreeFullActivationForm : Form
    {
        [UmbracoXmlAttribute("firstNameText")]
        public string FirstNameText { get; set; }
        [UmbracoXmlAttribute("lastNameText")]
        public string LastNameText { get; set; }
        [UmbracoXmlAttribute("emailText")]
        public string EmailText { get; set; }
        [UmbracoXmlAttribute("phoneText")]
        public string PhoneText { get; set; }
        [UmbracoXmlAttribute("countryText")]
        public string CountryText { get; set; }
        [UmbracoXmlAttribute("cityText")]
        public string CityText { get; set; }
        [UmbracoXmlAttribute("addressText")]
        public string AddressText { get; set; }
        [UmbracoXmlAttribute("appCodeText")]
        public string AppCodeText { get; set; }
        public FreeFullActivationForm(string xPath) : base(xPath) { }
        public FreeFullActivationForm(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("GoogleSiteMap")]
    public class GoogleSiteMap : UmbracoXmlEntry
    {
        public GoogleSiteMap(string xPath) : base(xPath) { }
        public GoogleSiteMap(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("HomePage")]
    public class HomePage : Master
    {
        [UmbracoXmlAttribute("changeLanguageText")]
        public string ChangeLanguageText { get; set; }
        [UmbracoXmlAttribute("rightCalloutText")]
        public string RightCalloutText { get; set; }
        [UmbracoXmlAttribute("helpPage")]
        public Int32? HelpPage { get; set; }
        public HomePage(string xPath) : base(xPath) { }
        public HomePage(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("HomePageImage")]
    public class HomePageImage : Settings
    {
        [UmbracoXmlAttribute("imageName")]
        public string Imagename { get; set; }
        [UmbracoXmlAttribute("image")]
        public Int32? Image { get; set; }
        [UmbracoXmlAttribute("link")]
        public Int32? Link { get; set; }
        public HomePageImage(string xPath) : base(xPath) { }
        public HomePageImage(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("LanguageHolder")]
    public class LanguageHolder : UmbracoXmlEntry
    {
        public LanguageHolder(string xPath) : base(xPath) { }
        public LanguageHolder(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("Master")]
    public class Master : UmbracoXmlEntry
    {
        [UmbracoXmlAttribute("title")]
        public string Title { get; set; }
        [UmbracoXmlAttribute("umbracoNaviHide")]
        public Int32? UmbracoNaviHide { get; set; }
        [UmbracoXmlAttribute("includeInFooter")]
        public Int32? Includeinfooter { get; set; }
        [UmbracoXmlAttribute("mETAKeywords")]
        public string METAKeywords { get; set; }
        [UmbracoXmlAttribute("mETADescription")]
        public string METADescription { get; set; }
        public Master(string xPath) : base(xPath) { }
        public Master(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("NewsItem")]
    public class NewsItem : Master
    {
        [UmbracoXmlAttribute("newsContent")]
        public string Newscontent { get; set; }
        [UmbracoXmlAttribute("dateOfRelease")]
        public string Dateofrelease { get; set; }
        [UmbracoXmlAttribute("shortDescription")]
        public string ShortDescription { get; set; }
        public NewsItem(string xPath) : base(xPath) { }
        public NewsItem(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("NewsLanding")]
    public class NewsLanding : Master
    {
        [UmbracoXmlAttribute("homeLatestNewsTitle")]
        public string Homelatestnewstitle { get; set; }
        public NewsLanding(string xPath) : base(xPath) { }
        public NewsLanding(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("Redirect301")]
    public class Redirect301 : UmbracoXmlEntry
    {
        [UmbracoXmlAttribute("redirectToPage")]
        public Int32? RedirectToPage { get; set; }
        public Redirect301(string xPath) : base(xPath) { }
        public Redirect301(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("Release")]
    public class Release : UmbracoXmlEntry
    {
        [UmbracoXmlAttribute("version")]
        public string Version { get; set; }
        [UmbracoXmlAttribute("major")]
        public string Major { get; set; }
        [UmbracoXmlAttribute("minor")]
        public string Minor { get; set; }
        [UmbracoXmlAttribute("build")]
        public string Build { get; set; }
        [UmbracoXmlAttribute("installerFile")]
        public Int32? InstallerFile { get; set; }
        [UmbracoXmlAttribute("productName")]
        public string Productname { get; set; }
        [UmbracoXmlAttribute("dateOfRelease")]
        public string Dateofrelease { get; set; }
        [UmbracoXmlAttribute("programVersion")]
        public Int32? ProgramVersion { get; set; }
        [UmbracoXmlAttribute("releaseNotes")]
        public string Releasenotes { get; set; }
        [UmbracoXmlAttribute("releaseText")]
        public string ReleaseText { get; set; }
        [UmbracoXmlAttribute("isStable")]
        public Int32? IsStable { get; set; }
        [UmbracoXmlAttribute("displayCounter")]
        public Int32? DisplayCounter { get; set; }
        [UmbracoXmlAttribute("versionInfo")]
        public string VersionInfo { get; set; }
        public Release(string xPath) : base(xPath) { }
        public Release(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("ReleasesHolder")]
    public class ReleasesHolder : UmbracoXmlEntry
    {
        [UmbracoXmlAttribute("downloadText")]
        public string Downloadtext { get; set; }
        [UmbracoXmlAttribute("buildText")]
        public string Buildtext { get; set; }
        [UmbracoXmlAttribute("downloadsCountText")]
        public string DownloadscountText { get; set; }
        public ReleasesHolder(string xPath) : base(xPath) { }
        public ReleasesHolder(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("Settings")]
    public class Settings : UmbracoXmlEntry
    {
        public Settings(string xPath) : base(xPath) { }
        public Settings(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("SettingsHomePage")]
    public class SettingsHomePage : Settings
    {
        public SettingsHomePage(string xPath) : base(xPath) { }
        public SettingsHomePage(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("SimplePage")]
    public class SimplePage : Master
    {
        [UmbracoXmlAttribute("pageContent")]
        public string Pagecontent { get; set; }
        public SimplePage(string xPath) : base(xPath) { }
        public SimplePage(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("SiteSettings")]
    public class SiteSettings : Settings
    {
        [UmbracoXmlAttribute("subjectText")]
        public string Subjecttext { get; set; }
        [UmbracoXmlAttribute("fromEmail")]
        public string FromEmail { get; set; }
        [UmbracoXmlAttribute("mailTo")]
        public string Mailto { get; set; }
        [UmbracoXmlAttribute("sMTPServer")]
        public string SMTPserver { get; set; }
        [UmbracoXmlAttribute("sMTPPort")]
        public Int32? SMTPport { get; set; }
        public SiteSettings(string xPath) : base(xPath) { }
        public SiteSettings(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("SiteSettingsLanguage")]
    public class SiteSettingsLanguage : Settings
    {
        [UmbracoXmlAttribute("languageName")]
        public string LanguageName { get; set; }
        [UmbracoXmlAttribute("siteSlogan")]
        public string SiteSlogan { get; set; }
        [UmbracoXmlAttribute("siteMainSearchTerm")]
        public string Sitemainsearchterm { get; set; }
        public SiteSettingsLanguage(string xPath) : base(xPath) { }
        public SiteSettingsLanguage(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("UnInstallReason")]
    public class UnInstallReason : Master
    {
        [UmbracoXmlAttribute("submitText")]
        public string SubmitText { get; set; }
        [UmbracoXmlAttribute("requiredText")]
        public string RequiredText { get; set; }
        [UmbracoXmlAttribute("nameText")]
        public string NameText { get; set; }
        [UmbracoXmlAttribute("emailText")]
        public string EmailText { get; set; }
        [UmbracoXmlAttribute("messageText")]
        public string MessageText { get; set; }
        [UmbracoXmlAttribute("thankYouMessage")]
        public string ThankYouMessage { get; set; }
        public UnInstallReason(string xPath) : base(xPath) { }
        public UnInstallReason(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("VersionLog")]
    public class VersionLog : Master
    {
        [UmbracoXmlAttribute("changesText")]
        public string ChangesText { get; set; }
        public VersionLog(string xPath) : base(xPath) { }
        public VersionLog(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("XmlUpdateCheck")]
    public class XmlUpdateCheck : UmbracoXmlEntry
    {
        public XmlUpdateCheck(string xPath) : base(xPath) { }
        public XmlUpdateCheck(int id) : base(id) { }
    }
    [UmbracoXmlAttribute("File")]
    public class MediaFile : UmbracoMediaXmlEntry
    {
        [UmbracoXmlAttribute("umbracoFile")]
        public string Uploadfile { get; set; }
        [UmbracoXmlAttribute("umbracoExtension")]
        public string Type { get; set; }
        [UmbracoXmlAttribute("umbracoBytes")]
        public string Size { get; set; }
        public MediaFile(int id, bool deep) : base(id, deep) { }
    }
    [UmbracoXmlAttribute("Folder")]
    public class MediaFolder : UmbracoMediaXmlEntry
    {
        [UmbracoXmlAttribute("contents")]
        public string Contents { get; set; }
        public MediaFolder(int id, bool deep) : base(id, deep) { }
    }
    [UmbracoXmlAttribute("Image")]
    public class MediaImage : UmbracoMediaXmlEntry
    {
        [UmbracoXmlAttribute("umbracoFile")]
        public string Uploadimage { get; set; }
        [UmbracoXmlAttribute("umbracoWidth")]
        public string Width { get; set; }
        [UmbracoXmlAttribute("umbracoHeight")]
        public string Height { get; set; }
        [UmbracoXmlAttribute("umbracoBytes")]
        public string Size { get; set; }
        [UmbracoXmlAttribute("umbracoExtension")]
        public string Type { get; set; }
        public MediaImage(int id, bool deep) : base(id, deep) { }
    }
    [UmbracoXmlAttribute("Release")]
    public class MediaRelease : UmbracoMediaXmlEntry
    {
        [UmbracoXmlAttribute("installerFile")]
        public string InstallerFile { get; set; }
        public MediaRelease(int id, bool deep) : base(id, deep) { }
    }
    [UmbracoXmlAttribute("ReleaseFolder")]
    public class MediaReleaseFolder : UmbracoMediaXmlEntry
    {
        public MediaReleaseFolder(int id, bool deep) : base(id, deep) { }
    }
    [UmbracoXmlAttribute("ReleaseHolder")]
    public class MediaReleaseHolder : UmbracoMediaXmlEntry
    {
        public MediaReleaseHolder(int id, bool deep) : base(id, deep) { }
    }
}
