using System;
using System.Web;

namespace UmbracoXmlModel
{
    public class ModelHandler : IHttpHandler
    {
        public ModelHandler()
        {
        }
        public void ProcessRequest(HttpContext context)
        {
            HttpRequest Request = context.Request;
            HttpResponse Response = context.Response;

            Response.Write("<html>");
            Response.Write("<body>");
            string model = UmbracoXmlEntry.XmlCSharpModel;
            model = model.Replace("<", @"&lt;").Replace("<", @"&gt;").Replace(Environment.NewLine, @"<br />");
            Response.Write(model);
            Response.Write("</body>");
            Response.Write("</html>");
        }
        public bool IsReusable
        {
            // To enable pooling, return true here.
            // This keeps the handler in memory.
            get { return false; }
        }
    }
}
