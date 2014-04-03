"use strict";

$(document).ready(function() {

    var BasicHTML = '\
<div class="doconline">\
    <div id="content">\
        <div id="doc"></div>\
        <div id="footer">\
             <p class="copyright">\
             Copyright &copy;  2001-2012 OTRS Team, All Rights Reserved.\
             - <a href="http://www.otrs.com/en/corporate-navigation/imprint/">Imprint</a>\
             </p>\
         </div>\
    </div>\
</div>';

    var $Content = $('body').children().detach();
    $('body').empty().append($.parseHTML(BasicHTML));
    $('div.doconline > div#content > div#doc').append($Content);

    // Docbook documentation
    if ($('div.navheader').length) {

        // Make table of contents collapsable
        $('.toc p b a').on('click', function() {
            $(this).parent().parent().next('dl').slideToggle('fast', function() {
                $(this).parent().toggleClass('closed');
            });
            return false;
        });

        // Add anchor link to scroll to the top of the page
        $('body').append('<a href="#top" id="totop">^ <span>Use Elevator</span></a>');
        $('#totop').on('click', function() {
            $('html,body').animate({scrollTop: '0px'}, 1000);
            return false;
        });

        $('.toc p b').append('<a href="">Hide</a>');
        $('.section .toc').prepend('<p><b>Article navigation <a href="">Hide</a></b></p>');

        $('#marginalia ul ul a').prepend('<i class="fa fa-chevron-right"></i>');
    }
    // API documentation
    else if ($('div.box > h1').length) {
        // Fiddle with DOM
    }
});
