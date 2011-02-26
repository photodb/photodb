using System.Configuration;
using System.Web;

namespace PhotoDBDatabase.Classes
{
    public class BaseManager
    {
        public static string ConnectionString
        {
            get
            {
                return ConfigurationManager.AppSettings["SiteDatabase"];
            }
        }

        public static string ClientIp
        {
            get
            {
                return HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
            }
        }

        public static string UserAgent
        {
            get
            {
                return HttpContext.Current.Request.ServerVariables["HTTP_USER_AGENT"];
            }
        }
    }
}
