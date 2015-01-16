"use strict";
/*jshint multistr:true */

$(document).ready(function() {
    var NavigationConfig, Languages, BasicHTML, $OriginalContent;

    Languages = {
        en: 'English (en)',
        de: 'Deutsch (de)',
        ja: '日本語 (ja)',
        ru: 'Русский (ru)',
        sw: 'Swahili (sw)',
        zh_CN: '简体中文 (zh_CN)'
    };

    NavigationConfig = [
        {
            Name: 'OTRS Admin Manual',
            Type: 'manual',
            Path: 'admin',
            Versions: [
                {
                    Version:  '4.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 4',
                    Languages: ['en']
                },
                {
                    Version:  '3.3',
                    HTMLPath: '3.3',
                    Name:     'OTRS 3.3',
                    Languages: ['en', 'de', 'ja', 'ru', 'sw']
                },
                {
                    Version:  '3.2',
                    HTMLPath: '3.2',
                    Name:     'OTRS 3.2',
                    Languages: ['en']
                }
            ]
        },
        {
            Name: 'OTRS Business Solution™ Manual',
            Type: 'manual',
            Path: 'otrs-business-solution',
            Versions: [
                {
                    Version:     '4.0',
                    HTMLPath:    'stable',
                    Name:        'OTRS 4',
                    Languages:   ['en'],
                    PDFPath:     'doc-otrsbusiness',
                    PDFFileName: 'otrs_business_solution_book.pdf'
                },
            ]
        },
        {
            Name: 'OTRS::ITSM Manual',
            Type: 'manual',
            Path: 'itsm',
            Versions: [
                {
                    Version:  '4.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS::ITSM 4',
                    Languages: ['en']
                },
                {
                    Version:  '3.3',
                    HTMLPath: '3.3',
                    Name:     'OTRS::ITSM 3.3',
                    Languages: ['en', 'de']
                },
                {
                    Version:  '3.2',
                    HTMLPath: '3.2',
                    Name:     'OTRS::ITSM 3.2',
                    Languages: ['en', 'de']
                }
            ]
        },
        {
            Name: 'OTRS Appliance Manual',
            Type: 'manual',
            Path: 'appliance',
            Versions: [
                {
                    Version:  '4.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 4 Appliance',
                    Languages: ['en', 'de', 'ru', 'sw', 'zh_CN']
                },
                {
                    Version:  '3.3',
                    HTMLPath: '3.3',
                    Name:     'OTRS 3.3 Appliance',
                    Languages: ['en', 'de', 'ru', 'sw', 'zh_CN']
                }
            ]
        },
        {
            Name: 'OTRS Developer Manual',
            Type: 'manual',
            Path: 'developer',
            Versions: [
                {
                    Version:  '4.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 4',
                    Languages: ['en']
                },
                {
                    Version:  '3.3',
                    HTMLPath: '3.3',
                    Name:     'OTRS 3.3',
                    Languages: ['en']
                },
                {
                    Version:  '3.2',
                    HTMLPath: '3.2',
                    Name:     'OTRS 3.2',
                    Languages: ['en']
                }
            ]
        },
        {
            Name: 'OTRS API Reference',
            Type: 'api',
            Path: 'otrs',
            Versions: [
                {
                    Version:  '5.0',
                    HTMLPath: '5.0',
                    Name:     'OTRS git (development)'
                },
                {
                    Version:  '4.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 4'
                },
                {
                    Version:  '3.3',
                    HTMLPath: '3.3',
                    Name:     'OTRS 3.3'
                },
                {
                    Version:  '3.2',
                    HTMLPath: '3.2',
                    Name:     'OTRS 3.2'
                }
            ]
        }
    ];

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
                        var Language    = Version.Languages[0];
                        var PDFPath     = 'doc-' + Category.Path;
                        var PDFFileName = 'otrs_' + Category.Path + '_book.pdf';

                        if (Version.PDFPath) {
                            PDFPath = Version.PDFPath;
                        }
                        if (Version.PDFFileName) {
                            PDFFileName = Version.PDFFileName;
                        }

                        Navigation += '<li><a href="' + BaseURL + 'manual/' + Category.Path + '/' + Version.HTMLPath + '/' + Language + '/html/index.html">HTML</a></li>';
                        Navigation += '<li><a href="http://ftp.otrs.org/pub/otrs/doc/' + PDFPath + '/' + Version.Version + '/' + Language + '/pdf/' + PDFFileName + '">PDF</a></li>';

                    }
                    else {
                        $.each(Version.Languages, function(){
                            var Language = this;
                            var PDFPath     = 'doc-' + Category.Path;
                            var PDFFileName = 'otrs_' + Category.Path + '_book.pdf';

                            if (Version.PDFPath) {
                                PDFPath = Version.PDFPath;
                            }
                            if (Version.PDFFileName) {
                                PDFFileName = Version.PDFFileName;
                            }

                            Navigation += '<li><a href="#">' + Languages[Language] + '</a><ul class="Hidden">';
                            Navigation += '<li><a href="' + BaseURL + 'manual/' + Category.Path + '/' + Version.HTMLPath + '/' + Language + '/html/index.html">HTML</a></li>';
                            Navigation += '<li><a href="http://ftp.otrs.org/pub/otrs/doc/' + PDFPath + '/' + Version.Version + '/' + Language + '/pdf/' + PDFFileName + '">PDF</a></li>';
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
                    Navigation += '<li><a href="' + BaseURL + 'api/' + Category.Path + '/' + Version.HTMLPath + '/index.html">' + Version.Name + '</a></li>';
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

    $.each($('#marginalia > li > a'), function() {
        var text = $(this).text();
        $(this).after('<span class="SectionHeader">' + text + '</span>');
        $(this).remove();
    });

    $('#marginalia li li a').bind('click', function() {
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

        $('div.toc p b').append('<a href="" class="toc-hide">Hide</a>');
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
