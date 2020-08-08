%{
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <vector>
#include <algorithm>
using namespace std;
// int u=0/*, us=0, uss=0*/;   // unit, unit section, unit subsection
int u=0;
vector<string> un;
// map<string, vector<string> > kwi;// keyword index
map<int, vector<string> > fixme;
map<int, vector<string> > kwi;// keyword index
%}
%option noyywrap
%x INCLUDE
%x BODY
%%
%{
// string sectionNumber();
%}
<INCLUDE>{
    ^#(?i:end)" "*$  { BEGIN(INITIAL); }
    .|\n             { cout << yytext; }
}

^#(?i:pre)" "*$  { BEGIN(INCLUDE); }

^.*\n\*\*\*+      { u++; /*us=0; uss=0*/;
                    string str(yytext);
                    un.push_back(str.substr(0,str.find('\n')+1));
                    }
^.*\n"=="=+       { /*us++; uss=0*/; }
^.*\n"--"-+       { /*uss++;*/ }

"!!"([^!\n]"!"?)*"!!"   {
                            string kw(yytext);
                            kw = kw.substr(2,yyleng-4);
                            std::transform(kw.begin(), kw.end(), kw.begin(),
                                [](unsigned char c){ return std::tolower(c); });
                            // kwi[sectionNumber()].push_back(kw);
                            kwi[u-1].push_back(kw);
                        }
"(("(?i:fixme)"))" { 
                    stringstream ss;
                    ss << "fixme" << fixme.size();
                    fixme[u-1].push_back(ss.str());
                    }

.|\n                    {}


%%
/*string sectionNumber(){
    stringstream ss;
    ss << u;
    if(us > 0 || uss > 0){
        ss << '.' << us;
        if(uss > 0 ){
            ss << '.' << uss;
        }
    }
    return ss.str();
}*/
int main(int argc, char** argv){
    if (argc == 1){
        yylex();
    }else{
        for(int i = 1; i < argc; i++){
            yyin = fopen(argv[i],"r");
            if(!yyin){
                cerr << "Couldn't open " << argv[i] << endl;
            }else{
                yylex();
            }
        }
        // WE PRINT MYINDEX COMMAND
        cout << "\\newcommand{\\myindex}{" << endl;
            if(un.size() > 0){
                cout << "\\tableofcontents";
            }       
        cout << "}" << endl;
        // WE PRINT MYGLOSSARY COMMAND WITH THE KEYWORDS
        cout << "\\newcommand{\\myglossary}{" << endl;
            for(int i=0; i < un.size(); i++){
                if(kwi.find(i) != kwi.end()){
                    // cout << "    " << i.first << endl;
                    cout << "    \\textbf{" << un[i] << "}" << endl;
                    cout << "    \\begin{multicols}{3}" << endl;
                    cout << "    \\begin{itemize}[label={}]" << endl;
                    // for(auto ii : i.second){
                    for(auto ii : kwi[i]){
                        cout << "        \\item \\hyperref[kw:" << ii << "]{" << ii << ", \\pageref*{kw:" << ii << "}}" << endl;
                    }
                    cout << "    \\end{itemize}" << endl;
                    cout << "    \\end{multicols}" << endl;
                }
            }       
        cout << "}" << endl;
        // WE PRINT THE FIXMELIST COMMAND
        cout << "\\newcommand{\\fixmelist}{" << endl;
            for(int i=0; i < un.size(); i++){
                if(fixme.find(i) != fixme.end()){
                    // cout << "    " << i.first << endl;
                    cout << "    \\textbf{" << un[i] << "}" << endl;
                    cout << "    \\begin{multicols}{3}" << endl;
                    cout << "    \\begin{itemize}[label={}]" << endl;
                    // for(auto ii : i.second){
                    for(auto ii : fixme[i]){
                        cout << "        \\item \\hyperref[" << ii << "]{" << string(ii).insert(5,"\\_") << ", \\pageref*{" << ii << "}}" << endl; 
                    }
                    cout << "    \\end{itemize}" << endl;
                    cout << "    \\end{multicols}" << endl;
                }
            }       
        cout << "}" << endl;
    }
    return 0;
}
