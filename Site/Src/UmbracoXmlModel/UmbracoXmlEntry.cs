using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Xml;
using System.Xml.XPath;
using umbraco.cms.businesslogic;
using umbraco.cms.businesslogic.datatype;
using umbraco.cms.businesslogic.media;
using umbraco.cms.businesslogic.propertytype;
using umbraco.cms.businesslogic.web;
using umbraco.NodeFactory;

namespace UmbracoXmlModel
{
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Class, Inherited = true, AllowMultiple = false)]
    public sealed class UmbracoXmlAttribute : Attribute
    {
        private string _alias;
        public UmbracoXmlAttribute(string alias)
        {
            _alias = alias;
        }
        public string Alias { get { return _alias; } }
    }
    [AttributeUsage(AttributeTargets.Method, Inherited = true, AllowMultiple = false)]
    public sealed class UmbracoXmlMappingMethodAttribute : Attribute
    {
        public UmbracoXmlMappingMethodAttribute() { }
    }

    public class UmbracoBaseXmlEntry
    {
        private string _nodeName = String.Empty;
        private int _id = -1;
        private int _parentId = -1;
        private int _level = 0;
        private bool _empty = true;
        private Dictionary<string, string> _values = new Dictionary<string, string>();

        public void LoadFromXPath(XPathNavigator xPath)
        {
            if (xPath == null)
                throw new ArgumentNullException("xpath");

            _nodeName = xPath.GetAttribute("nodeName", "");
            Int32.TryParse(xPath.GetAttribute("id", ""), out _id);
            Int32.TryParse(xPath.GetAttribute("parentID", ""), out _parentId);
            Int32.TryParse(xPath.GetAttribute("level", ""), out _level);
            var result = xPath.SelectChildren(XPathNodeType.Element);
            while (result.MoveNext())
            {
                if (result.Current != null && !result.Current.HasAttributes)
                    _values.Add(result.Current.Name, result.Current.Value);
            }
            BindFields();
            _empty = false;
        }

        private void BindFields()
        {
            Type t = GetType();
            foreach (PropertyInfo pi in t.GetProperties())
            {
                object[] attrs = pi.GetCustomAttributes(typeof(UmbracoXmlAttribute), true);
                if (attrs.Length == 1)
                {
                    UmbracoXmlAttribute a = attrs[0] as UmbracoXmlAttribute;
                    if (a != null)
                    {
                        if (pi.PropertyType != typeof(Int32?))
                        {
                            pi.SetValue(this, this[a.Alias], new object[] { });
                        }
                        else
                        {
                            string value = this[a.Alias];
                            int iValue;
                            if (Int32.TryParse(value, out iValue))
                                pi.SetValue(this, iValue, new object[] { });
                            else
                                pi.SetValue(this, null, new object[] { });
                        }
                    }
                }
            }
        }

        public bool Empty
        {
            get
            {
                return _empty;
            }
        }

        public int Id
        {
            get
            {
                return _id;
            }
        }

        public int ParentId
        {
            get
            {
                return _parentId;
            }
        }

        public int Level
        {
            get
            {
                return _level;
            }
        }

        public string Url
        {
            get
            {
                return umbraco.library.NiceUrl(Id);
            }
        }

        public string NodeName
        {
            get
            {
                return _nodeName;
            }
        }

        public string this[string key]
        {
            get
            {
                if (_values.ContainsKey(key))
                    return _values[key] ?? String.Empty;

                return String.Empty;
            }
        }

        public static DBTypes GetDBType(DataTypeDefinition dtd)
        {
            var param = umbraco.BusinessLogic.Application.SqlHelper.CreateParameter("@nodeId", dtd.Id);
            var dbTypeString = umbraco.BusinessLogic.Application.SqlHelper.ExecuteScalar<string>("SELECT [dbType] FROM [cmsDataType] WHERE [nodeId] = @nodeId", param);
            return (DBTypes)Enum.Parse(typeof(DBTypes), dbTypeString);
        }

        protected virtual Type GetTypeByAlias(string alias)
        {
            return null;
        }

        public List<T> GetAllEntitiesByType<T>() where T : UmbracoBaseXmlEntry
        {
            List<T> result = new List<T>();

            Type t = typeof(T);
            object[] attrs = t.GetCustomAttributes(typeof(UmbracoXmlAttribute), true);
            if (attrs.Length == 1)
            {
                UmbracoXmlAttribute a = attrs[0] as UmbracoXmlAttribute;
                if (a != null)
                    throw new NotImplementedException();
            }

            return result;
        }

        public T ParentAsType<T>() where T : UmbracoBaseXmlEntry
        {
            if (ParentId > 0)
            {
                XPathNodeIterator it = umbraco.library.GetXmlNodeById(ParentId.ToString());
                if (it.Count == 1)
                {
                    string type = it.Current.Name;
                    T entity = Activator.CreateInstance(GetTypeByAlias(type), new object[] { -1 }) as T;
                    if (entity != null)
                    {
                        it.MoveNext();
                        entity.LoadFromXPath(it.Current);
                        return entity;
                    }
                }
            }
            return null;
        }

    }

    /// <summary>
    /// This entity works only with umbraco XML schema without querying DB
    /// </summary>
    public class UmbracoXmlEntry : UmbracoBaseXmlEntry
    {
        public UmbracoXmlEntry(int id)
        {
            //for internal use
            if (id == -1)
                return;

            XPathNodeIterator it = umbraco.library.GetXmlNodeById(id.ToString());
            if (it.Count == 1)
            {
                it.MoveNext();
                LoadFromXPath(it.Current.Clone());
            }
        }

        public UmbracoXmlEntry(string xPath)
        {
            XPathNodeIterator it = umbraco.library.GetXmlNodeByXPath(xPath);
            if (it.Count > 0)
            {
                it.MoveNext();
                LoadFromXPath(it.Current.Clone());
            }
        }

        public static UmbracoXmlEntry Current
        {
            get
            {
                return new UmbracoXmlEntry(Node.getCurrentNodeId());
            }
        }

        protected override Type GetTypeByAlias(string alias)
        {
            return XmlTypeMapping.Instance[alias];
        }

        public List<T> ChildsOfType<T>() where T : UmbracoXmlEntry
        {
            List<T> result = new List<T>();

            XmlDocument umbracoXml = umbraco.content.Instance.XmlContent;
            string xPath = string.Format("root/descendant::*[@isDoc and @id = {0}]/child::*[@isDoc]", Id);
            XmlNodeList pages = umbracoXml.SelectNodes(xPath);
            foreach (XmlNode node in pages)
            {
                int id = Int32.Parse(node.Attributes["id"].Value);
                string type = node.Name;
                T entity = Activator.CreateInstance(GetTypeByAlias(type), new object[] { -1 }) as T;
                if (entity != null)
                {
                    entity.LoadFromXPath(node.CreateNavigator());
                    result.Add(entity);
                }
            }

            return result;
        }

        public static List<T> ParseList<T>(string nodeList) where T : UmbracoXmlEntry
        {
            List<T> result = new List<T>();
            if (!string.IsNullOrWhiteSpace(nodeList))
            {
                string[] ids = nodeList.Split(',');
                foreach (string id in ids)
                {
                    int iID;
                    if (Int32.TryParse(id, out iID))
                    {
                        XPathNodeIterator it = umbraco.library.GetXmlNodeById(iID.ToString());
                        if (it.Count == 1)
                        {
                            it.MoveNext();
                            string type = it.Current.Name;
                            T entity = Activator.CreateInstance(XmlTypeMapping.Instance[type], new object[] { iID }) as T;
                            if (entity != null)
                                result.Add(entity);
                        }
                    }
                }
            }
            return result;
        }


        public static List<String> ParseLists(string nodeList)
        {
            List<String> result = new List<String>();
            if (!string.IsNullOrWhiteSpace(nodeList))
            {
                string[] ids = nodeList.Split(',');
                foreach (string id in ids)
                {
                    //int iID;
                    //if (Int32.TryParse(id, out iID))
                    //{
                    //    XPathNodeIterator it = umbraco.library.GetXmlNodeById(iID.ToString());
                    //    if (it.Count == 1)
                    //    {
                    //        it.MoveNext();
                    //        string type = it.Current.Name;
                    //        String entity = (String)Activator.CreateInstance(type, new object[] { iID });
                    //        if (entity != null)
                    //            result.Add(entity);
                    //    }
                    //}

                    result.Add(id);
                }
            }
            return result;
        }

        private static void FillMasterProperties(IEnumerable<ContentType> cts, int docTypeId, List<string> propAliasList)
        {
            if (docTypeId <= 0)
                return;

            ContentType dt = cts.Where(x => x.Id == docTypeId).First();
            foreach (PropertyType pt in dt.PropertyTypes)
            {
                if (!propAliasList.Contains(pt.Alias))
                    propAliasList.Add(pt.Alias);
            }
            FillMasterProperties(cts, dt.MasterContentType, propAliasList);
        }

        private static string BuildClassName(string alias, bool isMedia)
        {
            return (isMedia && alias != "UmbracoMediaXmlEntry" ? "Media" : String.Empty) + alias;
        }

        public static void BuiltContentTypeList(IEnumerable<ContentType> cts, StringBuilder sb, string baseType, bool isMedia)
        {
            foreach (ContentType ct in cts)
            {
                string parentType = baseType;
                if (ct.MasterContentType > 0)
                {
                    ContentType t = cts.Where(x => x.Id == ct.MasterContentType).First();
                    parentType = t.Alias;
                }
                sb.AppendLine(String.Format(@"[UmbracoXmlAttribute(""{0}"")]", ct.Alias));
                sb.AppendLine(String.Format("public class {0} : {1} {{", BuildClassName(ct.Alias, isMedia), BuildClassName(parentType, isMedia)));

                List<string> masterProperties = new List<string>();
                FillMasterProperties(cts, ct.MasterContentType, masterProperties);
                foreach (PropertyType pt in ct.PropertyTypes)
                {
                    if (masterProperties.Contains(pt.Alias))
                        continue;

                    sb.AppendLine(String.Format(@"[UmbracoXmlAttribute(""{0}"")]", pt.Alias));
                    string name = pt.Name.Replace(" ", "").Replace("-", "").Replace(@"/", "").Replace(@"\", "").Replace(@":", "");

                    switch (GetDBType(pt.DataTypeDefinition))
                    {
                        case DBTypes.Integer:
                            sb.AppendLine(String.Format("public Int32? {0} {{ get; set; }}", name));
                            break;
                        default:
                            sb.AppendLine(String.Format("public string {0} {{ get; set; }}", name));
                            break;
                    }
                }

                if (!isMedia)
                {
                    sb.AppendLine(String.Format("public {0}(string xPath) : base(xPath) {{ }}", BuildClassName(ct.Alias, isMedia)));
                    sb.AppendLine(String.Format("public {0}(int id) : base(id) {{ }}", BuildClassName(ct.Alias, isMedia)));
                }
                else
                {
                    sb.AppendLine(String.Format("public {0}(int id, bool deep) : base(id, deep) {{ }}", BuildClassName(ct.Alias, isMedia)));
                }
                sb.AppendLine("}");
            }
        }

        public static string XmlCSharpModel
        {
            get
            {
                StringBuilder sb = new StringBuilder();

                List<MediaType> mts = MediaType.GetAllAsList().ToList();
                List<DocumentType> dts = DocumentType.GetAllAsList();

                #region Doc type mapping

                sb.AppendLine("public partial class XmlTypeMapping {");
                sb.AppendLine("[UmbracoXmlMappingMethodAttribute()]");
                sb.AppendLine("private void LoadTypeList() {");

                foreach (DocumentType dt in dts)
                    sb.AppendLine(String.Format(@"_mapping.Add(""{0}"", typeof({0}));", dt.Alias));

                sb.AppendLine("}");

                sb.AppendLine("}");

                #endregion

                #region Media type mapping

                sb.AppendLine("public partial class MediaXmlTypeMapping {");
                sb.AppendLine("[UmbracoXmlMappingMethodAttribute()]");
                sb.AppendLine("private void LoadTypeList() {");

                foreach (MediaType mt in mts)
                    sb.AppendLine(String.Format(@"_mapping.Add(""{0}"", typeof(Media{0}));", mt.Alias));

                sb.AppendLine("}");

                sb.AppendLine("}");

                #endregion

                BuiltContentTypeList(dts, sb, "UmbracoXmlEntry", false);
                BuiltContentTypeList(mts, sb, "UmbracoMediaXmlEntry", true);

                return sb.ToString();
            }
        }
    }

    public class UmbracoMediaXmlEntry : UmbracoBaseXmlEntry
    {
        private bool _deep;
        private XPathNodeIterator _mediaXml;

        public UmbracoMediaXmlEntry(string xPath)
        {
            throw new NotImplementedException();
        }
        public UmbracoMediaXmlEntry(int id) : this(id, false) { }
        public UmbracoMediaXmlEntry(int id, bool deep)
        {
            _deep = deep;
            //for internal use
            if (id == -1)
                return;

            _mediaXml = umbraco.library.GetMedia(id, deep).Clone();
            if (_mediaXml.Count == 1)
            {
                _mediaXml.MoveNext();
                LoadFromXPath(_mediaXml.Current);
            }
        }

        protected override Type GetTypeByAlias(string alias)
        {
            return MediaXmlTypeMapping.Instance[alias];
        }

        public List<T> ChildsOfType<T>() where T : UmbracoMediaXmlEntry
        {
            List<T> items = new List<T>();

            object[] attrs = typeof(T).GetCustomAttributes(typeof(UmbracoXmlAttribute), true);
            if (attrs.Length == 1)
            {
                UmbracoXmlAttribute a = attrs[0] as UmbracoXmlAttribute;
                if (a == null)
                    throw new NotImplementedException();

                if (_deep)
                {
                    XPathNodeIterator it = _mediaXml.Current.Select(".//" + a.Alias);
                    while (it.MoveNext())
                    {
                        XPathNavigator nav = it.Current;
                        string type = nav.Name;
                        T entity = Activator.CreateInstance(GetTypeByAlias(type), new object[] { -1, false }) as T;
                        if (entity != null)
                        {
                            entity.LoadFromXPath(nav);
                            items.Add(entity);
                        }
                    }
                }
            }

            return items;
        }
    }

    public partial class XmlTypeMapping
    {
        private Dictionary<string, Type> _mapping = new Dictionary<string, Type>();
        private static XmlTypeMapping _instance = null;
        private XmlTypeMapping()
        {
            Type t = GetType();
            foreach (MethodInfo mi in t.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.NonPublic))
            {
                foreach(object attr in mi.GetCustomAttributes(false))
                {
                    if (attr is UmbracoXmlMappingMethodAttribute)
                        mi.Invoke(this, new object[] { });
                }
            }
        }
        public static XmlTypeMapping Instance 
        { 
            get 
            { 
                if (_instance == null) 
                    _instance = new XmlTypeMapping(); 
                
                return _instance; 
            } 
        }
        public Type this[string key] 
        {
            get 
            { 
                if (_mapping.ContainsKey(key)) 
                    return _mapping[key]; 
                return typeof(UmbracoXmlEntry); 
            } 
        }
    }

    public partial class MediaXmlTypeMapping
    {
        private Dictionary<string, Type> _mapping = new Dictionary<string, Type>();
        private static MediaXmlTypeMapping _instance = null;
        private MediaXmlTypeMapping()
        {
            Type t = GetType();
            foreach (MethodInfo mi in t.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.NonPublic))
            {
                foreach (object attr in mi.GetCustomAttributes(false))
                {
                    if (attr is UmbracoXmlMappingMethodAttribute)
                        mi.Invoke(this, new object[] { });
                }
            }
        }
        public static MediaXmlTypeMapping Instance 
        { 
            get 
            { 
                if (_instance == null) 
                    _instance = new MediaXmlTypeMapping(); 
                return _instance; 
            } 
        }
        public Type this[string key] 
        { 
            get 
            {
                if (_mapping.ContainsKey(key)) 
                    return _mapping[key]; 
                
                return typeof(UmbracoMediaXmlEntry); 
            } 
        }
    }
}
