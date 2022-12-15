vcl 4.0;

backend default {
    .host = "drupalexamen";
    .port = "80";
}

acl authorizedpurge {
    "8.8.4.4";
    "8.8.8.8";
    "drupalexamen";
}

sub vcl_recv {

    if (req.url ~ "^/status.php" 
        || req.url ~ "^/update.php"
        || req.url ~ "^/install.php$"
        || req.url ~ "^/apc.php$"
        || req.url ~ "^/admin$"
        || req.url ~ "^/admin/.*$"
        || req.url ~ "^/user$"
        || req.url ~ "^user/.*$"
        || req.url ~ "^/users.*$"
        || req.url ~ "^/info/.*$"
        || req.url ~ "^/flag$"
        || req.url ~ "^.*$/ajax/.*$"
        || req.url ~ "^.*$/ahah/.*$"
        || req.url ~ "^/system/files/.*$") {
        return (pass);
    }

    if (req.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|otf|ogg|ogm|opus|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
        unset req.http.Cookie;
        return (hash);
    }

    if (req.method == "PURGE") {
        if (client.ip ~ authorizedpurge) {
            return(purge);
        }
    }

    if (req.http.User-Agent ~ "Facebookexternalhit" 
        || req.http.User-Agent ~ "Twitterbot" 
        || req.http.User-Agent ~ "Google-Site-Verification" 
        || req.http.User-Agent ~ "Google Page Speed Insights")
    {
        return(pass);
    }

}

sub vcl_backend_response {

    if (bereq.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|otf|ogg|ogm|opus|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
        unset beresp.http.set-cookie;
    }

    if(bereq.url ~ "/assets/") {
        set beresp.ttl = 3 d;
    }

}
