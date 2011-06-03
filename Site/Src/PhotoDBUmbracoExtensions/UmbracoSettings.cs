using System;
using System.Xml;
using umbraco.NodeFactory;

namespace PhotoDBUmbracoExtensions
{
    public class UmbracoSettings
    {
        private static string GetSettingsValue(string key)
        {
            string xPath = string.Format("root/descendant-or-self::SiteSettings[@isDoc]");

            XmlDocument umbracoXml = umbraco.content.Instance.XmlContent;
            XmlNode settingsNode = umbracoXml.SelectSingleNode(xPath);

            int settingsId = Int32.Parse(settingsNode.Attributes["id"].Value);

            Node n = new Node(settingsId);
            return n.GetProperty(key).Value;
        }

        public static string SubjectText
        {
            get
            {
                return GetSettingsValue("subjectText");
            }
        }

        public static string FromEmail
        {
            get
            {
                return GetSettingsValue("fromEmail");
            }
        }

        public static string Mailto
        {
            get
            {
                return GetSettingsValue("mailTo");
            }
        }

        public static string SMTPServer
        {
            get
            {
                return GetSettingsValue("sMTPServer");
            }
        }

        public static int SMTPPort
        {
            get
            {
                return Int32.Parse(GetSettingsValue("sMTPPort"));
            }
        }
    }
}
