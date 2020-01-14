// --
// Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (GPL). If you
// did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
// --

"use strict";
/*jshint multistr:true */
/*global ga */

// Redirect to canonical URL https://doc.otrs.com/...
if (window.location.hostname == 'otrs.github.io') {
    window.location.hostname = 'doc.otrs.com';
}
if (window.location.protocol == 'http:') {
    window.location.protocol = 'https:';
}

$(document).ready(function() {
    var NavigationConfig, Languages, BasicHTML, $OriginalContent,
        CurrentDate = new Date();

    Languages = {
        en: 'English (en)',
        de: 'Deutsch (de)',
        hu: 'Magyar (hu)',
        ja: '日本語 (ja)',
        pt_BR: 'português brasileiro (pt_BR)',
        ru: 'Русский (ru)',
        sr: 'Српски (sr)',
        sw: 'Swahili (sw)',
        zh_CN: '简体中文 (zh_CN)'
    };

    NavigationConfig = [
        {
            Name: 'OTRS User Manual',
            Type: 'manual',
            Path: 'user',
            Versions: [
                {
                    Version:  '7.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 7',
                    Languages: ['en', 'de', 'hu', 'zh_CN'],
                    AssetPath:     'doc-user',
                    AssetFilename: 'otrs_user_manual'
                },
            ]
        },
        {
            Name: 'OTRS Admin Manual',
            Type: 'manual',
            Path: 'admin',
            Versions: [
                {
                    Version:  '7.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 7',
                    Languages: ['en', 'de', 'hu', 'zh_CN'],
                    AssetPath:     'doc-admin',
                    AssetFilename: 'otrs_admin_manual'
                },
                {
                    Version:  '6.0',
                    HTMLPath: '6.0',
                    Name:     'OTRS 6',
                    Languages: ['en', 'hu', 'zh_CN'],
                    AssetPath:     'doc-admin',
                    AssetFilename: 'otrs_admin_book'
                },
                {
                    Version:  '5.0',
                    HTMLPath: '5.0',
                    Name:     'OTRS 5',
                    Languages: ['en', 'hu', 'zh_CN'],
                    AssetPath:     'doc-admin',
                    AssetFilename: 'otrs_admin_book'
                },
            ]
        },
        {
            Name: 'OTRS Feature Add-ons Manual',
            Type: 'manual',
            Path: 'fao',
            Versions: [
                {
                    Version:  '7.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 7',
                    Languages: ['en', 'hu'],
                    AssetPath:     'doc-fao',
                    AssetFilename: 'otrs_fao_manual'
                }
            ]
        },
        {
            Name: 'OTRS Update Guide',
            Type: 'manual',
            Path: 'installation',
            Versions: [
                {
                    Version:  '7.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 7',
                    Languages: ['en', 'de', 'hu', 'zh_CN'],
                    AssetPath:     'doc-installation',
                    AssetFilename: 'otrs_installation_guide'
                }
            ]
        },
        {
            Name: 'OTRS Configuration Reference',
            Type: 'manual',
            Path: 'config-reference',
            Versions: [
                {
                    Version:  '7.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 7',
                    Languages: ['en', 'de', 'hu', 'pt_BR', 'sr', 'zh_CN'],
                    AssetPath:     'doc-config-reference',
                    AssetFilename: 'otrs_config_reference'
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
                    Languages:   ['en', 'de', 'hu', 'zh_CN'],
                    AssetPath:     'doc-otrsbusiness',
                    AssetFilename: 'otrs_business_solution_book'
                },
                {
                    Version:     '5.0',
                    HTMLPath:    '5.0',
                    Name:        'OTRS 5',
                    Languages:   ['en', 'pt_BR', 'hu'],
                    AssetPath:     'doc-otrsbusiness',
                    AssetFilename: 'otrs_business_solution_book'
                },
            ]
        },
        {
            Name: 'OTRS::ITSM Manual',
            Type: 'manual',
            Path: 'itsm',
            Versions: [
                {
                    Version:  '7.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS::ITSM 7',
                    Languages: ['en', 'de', 'hu', 'zh_CN'],
                    AssetPath:     'doc-itsm',
                    AssetFilename: 'otrs_itsm_manual'
                },
                {
                    Version:  '6.0',
                    HTMLPath: '6.0',
                    Name:     'OTRS::ITSM 6',
                    Languages: ['en', 'hu', 'ru', 'zh_CN'],
                    AssetPath:     'doc-itsm',
                    AssetFilename: 'otrs_itsm_book'
                },
                {
                    Version:  '5.0',
                    HTMLPath: '5.0',
                    Name:     'OTRS::ITSM 5',
                    Languages: ['en', 'hu', 'ru', 'zh_CN'],
                    AssetPath:     'doc-itsm',
                    AssetFilename: 'otrs_itsm_book'
                },
            ]
        },
        {
            Name: 'OTRS Developer Manual',
            Type: 'manual',
            Path: 'developer',
            Versions: [
                {
                    Version:  '7.0',
                    HTMLPath: 'stable',
                    Name:     'OTRS 7',
                    Languages: ['en', 'hu', 'zh_CN'],
                    AssetPath:     'doc-developer',
                    AssetFilename: 'otrs_developer_manual'
                },
                {
                    Version:  '6.0',
                    HTMLPath: '6.0',
                    Name:     'OTRS 6',
                    Languages: ['en', 'hu'],
                    AssetPath:     'doc-developer',
                    AssetFilename: 'otrs_developer_book'
                },
                {
                    Version:  '5.0',
                    HTMLPath: '5.0',
                    Name:     'OTRS 5',
                    Languages: ['en', 'hu'],
                    AssetPath:     'doc-developer',
                    AssetFilename: 'otrs_developer_book'
                },
            ]
        },
        {
            Name: 'OTRS API Reference',
            Type: 'api',
            Path: 'otrs',
            Versions: [
                {
                    Version:  '8.0',
                    HTMLPath: '8.0',
                    Types:    [
                        {
                            Name: 'Perl',
                            Path: 'Perl',
                        },
                        {
                            Name: 'Design System',
                            Path: 'frontend/dist/designsystem',
                            NewTab: true,
                        },
                        {
                            Name: 'JavaScript',
                            Path: 'frontend/dist/api',
                            NewTab: true,
                        },
                        {
                            Name: 'JavaScript (Admin Interface)',
                            Path: 'JavaScript',
                        },
                        {
                            Name: 'REST Interface',
                            Path: 'REST',
                            NewTab: true,
                        }
                    ],
                    Name:     'OTRS git (development)'
                },
                {
                    Version:  '7.0',
                    HTMLPath: 'stable',
                    Types:    [
                        {
                            Name: 'Perl',
                            Path: 'Perl',
                        },
                        {
                            Name: 'Design System (External Interface)',
                            Path: 'frontend/dist/designsystem',
                            NewTab: true,
                        },
                        {
                            Name: 'JavaScript (External Interface)',
                            Path: 'frontend/dist/api',
                            NewTab: true,
                        },
                        {
                            Name: 'JavaScript (Agent Interface)',
                            Path: 'JavaScript',
                        },
                        {
                            Name: 'REST Interface',
                            Path: 'REST',
                            NewTab: true,
                        }
                    ],
                    Name:     'OTRS 7'
                },
                {
                    Version:  '6.0',
                    HTMLPath: '6.0',
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
            ]
        }
    ];

    function CreateNavigation () {

        var BaseURL = window.location.href,
            Navigation = '<ul id="marginalia">';

        BaseURL = BaseURL.replace(/\/doc\/.*/, '/doc/');

        $.each(NavigationConfig, function() {
            var Category = this;

            Navigation += '<li><a href="#">' + Category.Name + '</a><ul>';

            // Manual
            if (Category.Type === 'manual') {
                $.each(Category.Versions, function() {
                    var Version = this,
                        ID = 'manual_' + Category.Path + '_' + Version.Version;

                    ID = ID.replace(/\./g, '_');

                    function CreateHTMLPath(Version, Language) {
                        if (parseFloat(Version.Version) >= 7.0) {
                            return BaseURL + 'manual/' + Category.Path + '/' + Version.HTMLPath + '/' + Language + '/content/index.html" target="_blank';
                        }
                        return BaseURL + 'manual/' + Category.Path + '/' + Version.HTMLPath + '/' + Language + '/html/index.html';
                    }

                    function CreatePDFPath(Version, Language, AssetPath, AssetFilename) {
                        if (Version.Version < 7.0) {
                            return 'http://ftp.otrs.org/pub/otrs/doc/' + AssetPath + '/' + Version.Version + '/' + Language + '/pdf/' + AssetFilename + '.pdf';
                        }
                        else {
                            return 'http://ftp.otrs.org/pub/otrs/doc/' + AssetPath + '/' + Version.Version + '/' + Language + '/' + AssetFilename + '_' + Version.Version + '_' + Language + '.pdf';
                        }
                    }

                    function CreateEPUBPath(Version, Language, AssetPath, AssetFilename) {
                        return 'http://ftp.otrs.org/pub/otrs/doc/' + AssetPath + '/' + Version.Version + '/' + Language + '/' + AssetFilename + '_' + Version.Version + '_' + Language + '.epub';
                    }

                    Navigation += '<li id="' + ID + '"><a href="#">' + Version.Name + '</a><ul class="Hidden">';
                    $.each(Version.Languages, function(){
                        var Language = this;

                        if (Version.Languages.length > 1) {
                            Navigation += '<li><a href="#">' + Languages[Language] + '</a><ul class="Hidden">';
                        }
                        Navigation += '<li><a href="' + CreateHTMLPath(Version, Language) + '">HTML</a></li>';
                        if (Version.Version >= 7.0) {
                            Navigation += '<li><a href="' + CreateEPUBPath(Version, Language, Version.AssetPath, Version.AssetFilename) + '">EPUB</a></li>';
                        }
                        Navigation += '<li><a href="' + CreatePDFPath(Version, Language, Version.AssetPath, Version.AssetFilename) + '">PDF</a></li>';

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
                        if (Type.Path == 'REST') {
                            Navigation += '<li><a href="#">' + Type.Name + '</a><ul class="Hidden">';

                            // HTML
                            Navigation += '<li><a href="' + BaseURL + 'api/' + Category.Path + '/' + Version.HTMLPath + '/' + Type.Path + '"';
                            if (Type.NewTab) {
                                Navigation += ' target="_blank"'
                            }
                            Navigation += '>HTML</a></li>';

                            // RAML
                            Navigation += '<li><a href="' + BaseURL + 'api/' + Category.Path + '/' + Version.HTMLPath + '/' + Type.Path + '/otrs.raml"';
                            if (Type.NewTab) {
                                Navigation += ' target="_blank"'
                            }
                            Navigation += '>RAML</a></li>';

                            Navigation += '</ul></li>';
                        }
                        else {
                            Navigation += '<li><a href="' + BaseURL + 'api/' + Category.Path + '/' + Version.HTMLPath + '/' + Type.Path + '"';
                            if (Type.NewTab) {
                                Navigation += ' target="_blank"'
                            }
                            Navigation += '>' + Type.Name + '</a></li>';
                        }
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
<div class="doconline">\
    <div id="content">\
        <div id="marginalia_wrapper">' + CreateNavigation() + '</div>\
        <div id="doc" class="intro">\
        </div>\
        <div id="footer">\
            <p class="copyright">\
                &copy; 2001-' + CurrentDate.getFullYear() + ' <a href="https://www.otrs.com/company/imprint/">OTRS Group</a>\
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
        if ($('.section div.toc dl > dt').length) {
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
            LocationHref = window.location.href;

        LinkHref     = LinkHref.replace(/[\w\d-]+\.html[#\w\d-.]*/g, '');
        LocationHref = LocationHref.replace(/[\w\d-]+\.html[#\w\d-.]*/g, '');

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
