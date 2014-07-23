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
                    Languages: ['en',],
                },
                {
                    Version:  '3.2',
                    Name:     'OTRS 3.2',
                    Languages: ['en',],
                },
                {
                    Version:  '3.1',
                    Name:     'OTRS 3.1',
                    Languages: ['en',],
                },
                {
                    Version:  '3.0',
                    Name:     'OTRS 3.0',
                    Languages: ['en', 'de', 'ru',],
                },
            ],
        },
        {
            Name: 'OTRS ITSM Manual',
            Type: 'manual',
            Path: 'itsm',
            Versions: [
                {
                    Version:  '3.3',
                    Name:     'OTRS ITSM 3.3',
                    Languages: ['en',],
                },
                {
                    Version:  '3.2',
                    Name:     'OTRS ITSM 3.2',
                    Languages: ['en', 'de',],
                },
                {
                    Version:  '2.0',
                    Name:     'OTRS ITSM 2.0',
                    Languages: ['en', 'de',],
                },
            ],
        },
        {
            Name: 'OTRS Appliance Manual',
            Type: 'manual',
            Path: 'appliance',
            Versions: [
                {
                    Version:  '3.3',
                    Name:     'OTRS 3.3 Appliance',
                    Languages: ['en',],
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
                    Languages: ['en',],
                },
                {
                    Version:  '3.2',
                    Name:     'OTRS 3.2',
                    Languages: ['en',],
                },
                {
                    Version:  '3.1',
                    Name:     'OTRS 3.1',
                    Languages: ['en',],
                },
                {
                    Version:  '3.0',
                    Name:     'OTRS 3.0',
                    Languages: ['en',],
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
                    Name:     'OTRS git',
                },
                {
                    Version:  '3.3',
                    Name:     'OTRS 3.3',
                },
                {
                    Version:  '3.2',
                    Name:     'OTRS 3.2',
                },
                {
                    Version:  '3.1',
                    Name:     'OTRS 3.1',
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

                    Navigation += '<li><a href="#">' + Version.Name + '</a><ul class="Hidden">';
                    if (Version.Languages.length === 1) {
                        var Language = Version.Languages[0];
                        Navigation += '<li><a href="' + BaseURL + 'manual/' + Category.Path + '/' + Version.Version + '/' + Language + '/html/index.html">HTML</a></li>';
                        Navigation += '<li><a href="http://ftp.otrs.org/pub/otrs/doc/doc-' + Category.Path + '/' + Version.Version + '/' + Language + '/pdf/otrs_' + Category.Path + '_book.pdf">PDF</a></li>';

                    }
                    else {
                        $.each(Version.Languages, function(){
                            var Language = this;
                            Navigation += '<li><a href="#">' + Languages[Language] + '</a><ul class="Hidden">';
                            Navigation += '<li><a href="' + BaseURL + 'manual/' + Category.Path + '/' + Version.Version + '/' + Language + '/html/index.html">HTML</a></li>';
                            Navigation += '<li><a href="http://ftp.otrs.org/pub/otrs/doc/doc-' + Category.Path + '/' + Version.Version + '/' + Language + '/pdf/otrs_' + Category.Path + '_book.pdf">PDF</a></li>';
                            Navigation += '</ul></li>';
                        });
                    }
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
<div id="Header">\
    <h1 class="CompanyName">Portal</h1>\
    <div id="Logo"></div>\
</div>\
<div id="Navigation">\
<!--\
    <ul>\
        <li class="" title="View Downloads">\
            <a href="/otrs/customer.pl?Action=CustomerDownloads" accesskey="y" title="Downloads (y)" >Downloads</a>\
        </li>\
    </ul>\
    <ul class="Individual">\
        <li class=""><a href="/otrs/customer.pl?Action=CustomerPreferences" title="Persönliche Einstellungen vornehmen">Einstellungen</a></li>\
        <li class="Last"><a id="LogoutButton" href="/otrs/customer.pl?Action=Logout">Marc Bonsels abmelden</a></li>\
    </ul>\
-->\
</div>\
<div class="doconline">\
    <div id="content">\
        <div id="marginalia_wrapper">' + CreateNavigation() + '</div>\
        <div id="doc"></div>\
        <div id="footer">\
            <p class="copyright">\
                &copy; 2001-2014 <a href="https://www.otrs.com/company/imprint/">OTRS Group</a>\
            </p>\
        </div>\
    </div>\
</div>';

    $OriginalContent = $('body').children().detach();
    $('body').empty().append($.parseHTML(BasicHTML));
    $('div.doconline > div#content > div#doc').append($OriginalContent);

    $('#marginalia a').bind('click', function() {
        if ($(this).attr('href') === '#') {
            $(this).next('ul').toggleClass('Hidden');
            return false;
        }
    });

    // Add anchor link to scroll to the top of the page
    $('body').append('<a href="#top" id="totop">^ <span>Use Elevator</span></a>');
    $('#totop').on('click', function() {
        $('html,body').animate({scrollTop: '0px'}, 1000);
        return false;
    });
    $('#marginalia ul ul a').prepend('<i class="fa fa-chevron-right"></i>');

    // Docbook documentation
    if ($('div.navheader').length) {

        $('body').addClass('manual');

        // Make table of contents collapsable
        $('.toc').on('click', 'p b a', function() {
            $(this).parent().parent().next('dl').slideToggle('fast', function() {
                $(this).parent().toggleClass('closed');
            });
            return false;
        });

        $('div.toc p b').append('<a href="">Hide</a>');
        $('.section div.toc').prepend('<p><b>Article navigation <a href="">Hide</a></b></p>');
        $('dl.toc').removeClass('toc');
    }
    // API documentation
    else if ($('div.box > h1').length) {
        // Fiddle with DOM
        $('body').addClass('api');
    }

    $('#marginalia a').each(function() {
        var LinkHref     = $(this).attr('href'),
            LocationHref = window.location.href,
            IsActive = false;

        LinkHref     = LinkHref.replace(/[\w\d-]+\.html[#\w\d-\.]*/g, '');
        LocationHref = LocationHref.replace(/[\w\d-]+\.html[#\w\d-\.]*/g, '');

        if (LocationHref.indexOf(LinkHref) > -1) {
            $(this).addClass('Active').parents('ul').removeClass('Hidden');
        }
    });
});
