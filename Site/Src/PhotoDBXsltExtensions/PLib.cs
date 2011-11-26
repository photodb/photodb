using System;
using System.IO;
using System.Web;
using System.Xml.XPath;
using PhotoDBDatabase.Classes;
using UmbracoXmlModel;

namespace PhotoDBXsltExtensions
{
    public class Plib
    {
        public static int GetDownloadCount(int mediaId)
        {
            return DownloadManager.GetDownloadCount(mediaId);
        }

        public static int GetFileSize(string fileName)
        {
            string filePath = HttpContext.Current.Server.MapPath(fileName);
            try
            {
                FileInfo fileInfo = new FileInfo(filePath);
                return (int)fileInfo.Length;
            }
            catch(Exception ex)
            {
                if (!String.IsNullOrEmpty(HttpContext.Current.Request["umbDebugShowTrace"]))
                    throw new InvalidProgramException(ex.ToString() + Environment.NewLine + filePath + Environment.NewLine + fileName);
                return -1;
            }
        }

        public static string FormatFileSize(int fileSize, string mbText)
        {
            return String.Format("{0} {1}", (fileSize / (1024.0 * 1024.0)).ToString("0.00"), mbText);
        }

        public static string Coalesce(string str1, string str2)
        {
            if (!String.IsNullOrEmpty(str1))
                return str1;

            return str2;
        }

        public static string Coalesce(string str1, string str2, string str3)
        {
            if (!String.IsNullOrEmpty(str1))
                return str1;

            if (!String.IsNullOrEmpty(str2))
                return str2;

            return str3;
        }

        public static string IIF(bool condition, string ifTrue, string ifFalse)
        {
            return condition ? ifTrue : ifFalse;
        }

        public static bool IsLoggedIntoBackend()
        {
            var u = umbraco.helper.GetCurrentUmbracoUser();
            if (u == null)
                return false;
            else
                return true;
        }

        public static int GetVersionBuild(string version)
        {
            string[] versionParts = version.Split('.');
            int build;
            if (versionParts.Length == 4 && Int32.TryParse(versionParts[3], out build))
                return build;

            return 0;
        }

        public static string ReplaceNewLineToHTML(int nodeId, string s)
        {
            UmbracoXmlEntry node = new UmbracoXmlEntry(nodeId);
   
            s = node[s];

            s = s.Replace("\r\n", "<br/>");
            s = s.Replace("\n", "<br/>");

            return s;
        }
    }
}
