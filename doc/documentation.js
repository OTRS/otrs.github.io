"use strict";
/*jshint multistr:true */

$(document).ready(function() {
    var NavigationConfig, Languages, BasicHTML, $OriginalContent;

    NavigationConfig = [
        {
            Name: 'OTRS Admin Manual',
            Type: 'manual',
            Path: 'admin',
            Versions: [
                {
                    Version:  '3.3',
                    Name:     'OTRS 3.3',
                    Languages: ['en'],
                },
            ],
        },
        {
            Name: 'OTRS Developer Manual',
            Type: 'manual',
            Path: 'developer',
            Versions: [
                {
                    Version:  '3.3',
                    Name:     'OTRS 3.3',
                    Languages: ['en'],
                },
            ],
        },
        {
            Name: 'OTRS API Reference',
            Type: 'api',
            Path: 'otrs',
            Versions: [
                {
                    Version:  '3.4',
                    Name:     'OTRS 3.4',
                },
            ],
        },
    ];

    Languages = {
        en: 'English',
        de: 'Deutsch',
        ru: 'Русский',
    };

    function CreateNavigation () {

        var BaseURL = window.location.href;
        BaseURL = BaseURL.replace(/\/doc\/.*/, '/doc/');

        var Navigation = '<ul id="marginalia">';
        $.each(NavigationConfig, function() {
            var Category = this;
            Navigation += '<li><a href="#">' + Category.Name + '</a><ul>';

            // Manual
            if (Category.Type === 'manual') {
                $.each(Category.Versions, function(){
                    var Version = this;
                    Navigation += '<li><a href="#">' + Version.Name + '</a><ul>';

                    $.each(Version.Languages, function(){
                        var Language = this;
                        Navigation += '<li><a href="#">' + Languages[Language] + '</a><ul>';
                        Navigation += '<li><a href="' + BaseURL + 'manual/' + Category.Path + '/' + Version.Version + '/' + Language + '/html/index.html">HTML</a></li>';
                        Navigation += '<li><a href="http://ftp.otrs.org/pub/otrs/doc/doc-' + Category.Path + '/' + Version.Version + '/' + Language + '/pdf/otrs_' + Category.Path + '_book.pdf">PDF</a></li>';
                        Navigation += '</ul></li>';
                    });

                    Navigation += '</ul></li>';
                });
            }
            // API
            else {
                $.each(Category.Versions, function(){
                    var Version = this;
                    Navigation += '<li><a href="' + BaseURL + 'api/' + Category.Path + '/' + Version.Version + '/index.html">' + Version.Name + '</a></li>';
                });
            }

            Navigation += '</ul></li>';

        });
        Navigation += '</ul>';

        return Navigation;
    }

    BasicHTML = '\
<div class="doconline">\
    <div id="content">\
        <div id="marginalia_wrapper">' + CreateNavigation() + '</div>\
        <div id="doc"></div>\
        <div id="footer">\
             <p class="copyright">\
             Copyright &copy;  2001-2012 OTRS Team, All Rights Reserved.\
             - <a href="http://www.otrs.com/en/corporate-navigation/imprint/">Imprint</a>\
             </p>\
         </div>\
    </div>\
</div>';

    $OriginalContent = $('body').children().detach();
    $('body').empty().append($.parseHTML(BasicHTML));
    $('div.doconline > div#content > div#doc').append($OriginalContent);

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
