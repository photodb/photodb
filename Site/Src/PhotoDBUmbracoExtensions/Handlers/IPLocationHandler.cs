using System.Globalization;
using System.Text;
using System.Web;
using PhotoDBUmbracoExtensions.Classes;
using PhotoDBUmbracoExtensions.MaxMind;

namespace PhotoDBUmbracoExtensions.Handlers
{
    public class IPLocationHandler : IHttpHandler
    {
        public IPLocationHandler()
        {
        }

        public void ProcessRequest(HttpContext context)
        {
            HttpRequest Request = context.Request;
            HttpResponse Response = context.Response;

            Response.ContentType = "application/json";
            Response.ContentEncoding = Encoding.UTF8;

            GeoLocation location = GeoIPHelper.GetIPLocation;
            if (location != null)
            {
                Response.Write(@"{ ""lat"": """ + location.Latitude.ToString(CultureInfo.InvariantCulture) + @""",  ""lng"": """ + location.Longitude.ToString(CultureInfo.InvariantCulture) + @""", ""text"": """ + location.Desc + @""" }");
            }
        }

        public bool IsReusable
        {
            // To enable pooling, return true here.
            // This keeps the handler in memory.
            get { return false; }
        }
    }

}
