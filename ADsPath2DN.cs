  
  string ADsPath2DN(string ADsPath) {
    string ldapServer="", dn0="", dn1="";
    System.Text.RegularExpressions.Regex regEx = new System.Text.RegularExpressions.Regex("(LDAP://[^/]+)(.+)?");
    System.Text.RegularExpressions.Match match = regEx.Match(ADsPath);
    if (match.Success) {
      ldapServer = match.Groups[1].Value;
      dn0 = match.Groups[2].Value;
    } else {
      ldapServer = "";
      dn0 = ADsPath;
    }
    if ( String.Equals(dn0,"/") ) {
      dn1 = dn0;
    } else {
      dn1 = "";
      foreach (string v in dn0.Split('/')) {
        string v1 = v.Trim();  if ( v1.Length > 0 ) dn1 = v1 + "," + dn1;
      }
      if ( dn1.Length > 0 ) {
        dn1 = dn1.Substring(0, dn1.Length-1);
        if ( ldapServer.Length > 0 ) dn1 = "/" + dn1;
      }
    }
    return ldapServer + dn1;
  }
