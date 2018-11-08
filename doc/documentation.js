"use strict";
/*jshint multistr:true */

$(document).ready(function() {
    var NavigationConfig, Languages, BasicHTML, $OriginalContent;

    Languages = {
        en: 'English (en)',
        de: 'Deutsch (de)',
        hu: 'Magyar (hu)',
        ja: '日本語 (ja)',
        pt_BR: 'português brasileiro (pt_BR)',
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
                /*
                {
                    Version:  '7.0',
                    HTMLPath: '7.0',
                    Name:     'OTRS 7',
                    Languages: ['en']
                },
                */
                {
                    Version:  '6.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 6',
                    Languages: ['en', 'hu', 'zh_CN']
                },
                {
                    Version:  '5.0',
                    HTMLPath: '5.0',
                    Name:     'OTRS 5',
                    Languages: ['en', 'hu', 'zh_CN']
                },
                {
                    Version:  '4.0',
                    HTMLPath: '4.0',
                    Name:     'OTRS 4',
                    Languages: ['en', 'de', 'hu', 'ja', 'ru', 'sw']
                }
            ]
        },
        {
            Name: 'OTRS Business Solution™ Manual',
            Type: 'manual',
            Path: 'otrs-business-solution',
            Versions: [
                {
                    Version:     '6.0',
                    HTMLPath:    'stable',
                    Name:        'OTRS 6',
                    Languages:   ['en', 'hu'],
                    PDFPath:     'doc-otrsbusiness',
                    PDFFileName: 'otrs_business_solution_book.pdf'
                },
                {
                    Version:     '5.0',
                    HTMLPath:    '5.0',
                    Name:        'OTRS 5',
                    Languages:   ['en', 'pt_BR', 'hu'],
                    PDFPath:     'doc-otrsbusiness',
                    PDFFileName: 'otrs_business_solution_book.pdf'
                },
                {
                    Version:     '4.0',
                    HTMLPath:    '4.0',
                    Name:        'OTRS 4',
                    Languages:   ['en', 'hu'],
                    PDFPath:     'doc-otrsbusiness',
                    PDFFileName: 'otrs_business_solution_book.pdf'
                }
            ]
        },
        {
            Name: 'OTRS::ITSM Manual',
            Type: 'manual',
            Path: 'itsm',
            Versions: [
                {
                    Version:  '6.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS::ITSM 6',
                    Languages: ['en', 'hu', 'ru', 'zh_CN']
                },
                {
                    Version:  '5.0',
                    HTMLPath: '5.0',
                    Name:     'OTRS::ITSM 5',
                    Languages: ['en', 'hu', 'ru', 'zh_CN']
                },
                {
                    Version:  '4.0',
                    HTMLPath: '4.0',
                    Name:     'OTRS::ITSM 4',
                    Languages: ['en', 'ru']
                }
            ]
        },
        {
            Name: 'OTRS Developer Manual',
            Type: 'manual',
            Path: 'developer',
            Versions: [
                {
                    Version:  '6.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 6',
                    Languages: ['en', 'hu']
                },
                {
                    Version:  '5.0',
                    HTMLPath: '5.0',
                    Name:     'OTRS 5',
                    Languages: ['en', 'hu']
                },
                {
                    Version:  '4.0',
                    HTMLPath: '4.0',
                    Name:     'OTRS 4',
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
                    Version:  '7.0',
                    HTMLPath: '7.0',
                    Types:    [
                        { 
                            Name: 'Perl',
                            Path: 'Perl',
                        },
                        {
                            Name: 'Design System (External Interface)',
                            Path: 'frontend/dist/designsystem',
                        },
                        {
                            Name: 'JavaScript (External Interface)',
                            Path: 'frontend/dist/api',
                        },
                        {
                            Name: 'JavaScript (Agent Interface)',
                            Path: 'JavaScript',
                        },
                        {
                            Name: 'Webapp REST Interface',
                            Path: 'REST',
                        }
                    ],
                    Name:     'OTRS git (development)'
                },
                {
                    Version:  '6.0',
                    HTMLPath: 'stable',
                    Types:    [
                        { 
                            Name: 'Perl',
                            Path: 'Perl',
                        },
                        {
                            Name: 'JavaScript',
                            Path: 'JavaScript',
                        },
                    ],
                    Name:     'OTRS 6'
                },
                {
                    Version:  '5.0',
                    HTMLPath: '5.0',
                    Types:    [
                        { 
                            Name: 'Perl',
                            Path: 'Perl',
                        },
                        {
                            Name: 'JavaScript',
                            Path: 'JavaScript',
                        },
                    ],
                    Name:     'OTRS 5'
                },
                {
                    Version:  '4.0',
                    HTMLPath: '4.0',
                    Types:    [
                        { 
                            Name: 'Perl',
                            Path: 'Perl',
                        },
                    ],
                    Name:     'OTRS 4'
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
                    var Version = this,
                        ID = 'manual_' + Category.Path + '_' + Version.Version;

                    ID = ID.replace(/\./g, '_');

                    function CreateHTMLPath(Version, Language) {
                        if (parseFloat(Version.Version) >= 7.0) {
                            return BaseURL + 'manual/' + Category.Path + '-beta/' + Version.HTMLPath + '/' + Language + '/index.html';
                        }
                        return BaseURL + 'manual/' + Category.Path + '/' + Version.HTMLPath + '/' + Language + '/html/index.html';
                    }

                    function CreatePDFPath(Version, Language, PDFPath, PDFFileName) {
                        return 'http://ftp.otrs.org/pub/otrs/doc/' + PDFPath + '/' + Version.Version + '/' + Language + '/pdf/' + PDFFileName;
                    }

                    Navigation += '<li id="' + ID + '"><a href="#">' + Version.Name + '</a><ul class="Hidden">';
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

                        if (Version.Languages.length > 1) {
                            Navigation += '<li><a href="#">' + Languages[Language] + '</a><ul class="Hidden">';
                        }
                        Navigation += '<li><a href="' + CreateHTMLPath(Version, Language) + '">HTML</a></li>';
                        Navigation += '<li><a href="' + CreatePDFPath(Version, Language, PDFPath, PDFFileName) + '">PDF</a></li>';
                        if (Version.Languages.length > 1) {
                            Navigation += '</ul></li>';
                        }
                    });
                    Navigation += '</ul></li>';
                });
            }
            // API
            else {
                $.each(Category.Versions, function(){
                    var Version = this,
                        ID = 'api_' + Category.Path + '_' + Version.Version;

                    ID = ID.replace(/\./g, '_');

                    Navigation += '<li id="' + ID + '"><a href="#">' + Version.Name + '</a><ul class="Hidden">';
                    $.each(Version.Types, function(){
                        var Type = this;
                        Navigation += '<li><a href="' + BaseURL + 'api/' + Category.Path + '/' + Version.HTMLPath + '/' + Type.Path + '"';
                        if (Type.Path === 'REST') {
                            Navigation += ' target="_blank"'
                        }
                        Navigation += '>' + Type.Name + '</a></li>';
                    });
                    Navigation += '</ul></li>';
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
        <div id="doc" class="intro">\
            <div class="github-teaser github-teaser--important">\
                <p>\
                    <i class="fa fa-lightbulb-o"></i> <strong>Did you know?</strong> The OTRS Group recently announced important open source strategy changes. Learn more about these changes on the new <a href="https://community.otrs.com/" target="_blank">OTRS community website</a>.\
                </p>\
            </div>\
        </div>\
        <div id="footer">\
            <p class="copyright">\
                &copy; 2001-2017 <a href="https://www.otrs.com/company/imprint/">OTRS Group</a>\
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

        $('div.toc p b').append('<a href="" class="toc-hide">Toggle</a>');

        // Article navigation, decorate if it has content, remove otherwise.
        if ( $('.section div.toc dl > dt').length ) {
            $('.section div.toc').prepend('<p><b>Article navigation <a href="">Toggle</a></b></p>');
        }
        else {
            $('.section div.toc').remove();

        }
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

    // Start Google Analytics Tracking
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
    ga('create', 'UA-28118796-2', 'auto');
    ga('send', 'pageview');
    // End Google Analytics Tracking

});
