//
//  Action.js
//  Download in Movies
//
//  Created by Adrian on 01/08/15.
//  Copyright (c) 2015 Adrian Kosmaczewski. All rights reserved.
//

var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        // We just need the URL of the current page in Safari
        arguments.completionFunction({ "url" : document.baseURI })
    },
    
    finalize: function(arguments) {
    }
    
};
    
var ExtensionPreprocessingJS = new Action
