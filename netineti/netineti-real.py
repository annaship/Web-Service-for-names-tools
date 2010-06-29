# Machine Learning based approach to find scientific names
# Input: Any text preferably in Engish
# Output : A list of scientific names

# Lakshmi Manohar Akella
# Marine Biological Laboratory
# Updated May 26 2010(ver 0.927)


import time
import nltk
import random


class NetiNetiTrain:
    
        def __init__(self,species_train=None,num_examples = None,irrelevant_text=None,neg_names=None,all_names = None,learning_algo = "NB"):
                if(species_train is None):
                        species_train = "species_train_big.txt"
                if(num_examples is None):
                        num_examples = 15000
                if(irrelevant_text is None):
                        irrelevant_text = "pictorialgeo.txt"
                if(neg_names is None):
                        neg_names = "neg_names.txt"
                if(all_names is None):
                        all_names = "millionnames.txt"
                self.species_train = species_train
                self._num_examples = num_examples
                self.irrelevant_text = irrelevant_text
                self.neg_names = neg_names
                self._all_names = all_names
                self.learning_algo = learning_algo
                self._buildTable()
                self._buildFeatures(self._getTrainingData())

        def _splitGet(self,fileName):
                pdata = open(fileName).read()
                tokens = pdata.split('\n')
                #remove trailing spaces
                tokens = map(lambda x:x.strip(),tokens)
                return(tokens)
                

        def _getTrainingData(self):
                
                ptokens = self._splitGet(self.species_train)
                nn = []
                for n in ptokens:
                        p = n.split()
                        if(len(p) ==2):
                                nn.append(p[0][0]+". "+p[1])

                if(len(ptokens)>self._num_examples+1):
                        ptokens = ptokens[:self._num_examples]
                ptokens = ptokens+nn[:360]
                #positive data
                tdata = [(pt,'taxon') for pt in ptokens]

                #negative data
                ndata=open(self.irrelevant_text).read()
                neg = open(self.neg_names).read()
                neg_names = neg.split("\n")
                ntokens = nltk.word_tokenize(ndata)
                nntokens = list(set(ntokens))
                bg = nltk.bigrams(ntokens)
                tg = nltk.trigrams(ntokens)
                n_tokens = nntokens+neg_names
                n_bg = bg
                n_tg = tg
                nn_bg = set(n_bg)
                tr = [ (a+' '+b,'not-a-taxon') for (a,b) in nn_bg]

                nn_tg = set(n_tg)
                tri = [(a+' '+b+' '+c,'not-a-taxon') for (a,b,c) in nn_tg]

                nn_tokens = [(a,'not-a-taxon') for a in n_tokens]

                #negative data
                nndata = nn_tokens+tr+tri

                allData = tdata+nndata
                random.shuffle(allData)
                allData = filter(lambda x: len(x[0])>=2,allData)
                return(allData)

        def _buildTable(self):
                ta = time.clock()
                ttokens = self._splitGet(self._all_names)
                self._tab_hash = {}
                for t in ttokens:
                        self._tab_hash[t] = 1
                tb = time.clock()
                print str(tb-ta)
                print len(self._tab_hash)

        def _populateFeatures(self,array,idx,start,stop,features,name):
                        
                try:
                        if(stop =="end"):
                                features[name] = array[idx][start:]
                        elif(stop =="sc"):
                                features[name] = array[idx][start]
                        else:
                                features[name] = array[idx][start:stop]
                except Exception:
                        features[name] = 'NA'
                return(features[name])
        
        def _incWeight(self,st_wt,inc,val):
                if(val):
                        return(st_wt+inc)
                else:
                        return(st_wt)

        def taxon_features(self,token):
                features = {}
                swt = 5 # Weight Increment
                vowels =['a','e','i','o','u']
                sv = ['a','i','s','m']#last letter (LL) weight
                sv1 =['e','o']# Reduced LL weight
                svlb = ['i','u']# penultimate L weight
                string_weight = 0
                
                prts = token.split(" ")
                self._populateFeatures(prts,0,-3,"end",features,"last3_first")
                self._populateFeatures(prts,1,-3,"end",features,"last3_second")
                self._populateFeatures(prts,2,-3,"end",features,"last3_third")
                self._populateFeatures(prts,0,-2,"end",features,"last2_first")
                self._populateFeatures(prts,1,-2,"end",features,"last2_second")
                self._populateFeatures(prts,2,-2,"end",features,"last2_third")
                self._populateFeatures(prts,0,0,"sc",features,"first_char")
                self._populateFeatures(prts,0,-1,"sc",features,"last_char")
                self._populateFeatures(prts,0,1,"sc",features,"second_char")
                self._populateFeatures(prts,0,-2,"sc",features,"sec_last_char")

                features["lastltr_of_fw_in_sv"] = j = self._populateFeatures(prts,0,-1,"sc",features,"lastltr_of_fw_in_sv") in sv
                string_weight = self._incWeight(string_weight,swt,j)
                features["lastltr_of_fw_in_svl"] = j = self._populateFeatures(prts,0,-1,"sc",features,"lastltr_of_fw_in_svl") in sv1
                string_weight = self._incWeight(string_weight,swt-3,j)
                features["lastltr_of_sw_in_sv"] = j = self._populateFeatures(prts,1,-1,"sc",features,"lastltr_of_sw_in_sv") in sv
                string_weight = self._incWeight(string_weight,swt,j)
                features["lastltr_of_sw_in_svl"] = j = self._populateFeatures(prts,1,-1,"sc",features,"lastltr_of_sw_in_svl") in sv1
                string_weight = self._incWeight(string_weight,swt-3,j)
                features["lastltr_of_tw_in_sv_or_svl"] = j = self._populateFeatures(prts,2,-1,"sc",features,"lastltr_of_tw_in_sv_or_svl") in sv+sv1
                string_weight = self._incWeight(string_weight,swt-2,j)
                features["last_letter_fw_vwl"] = prts[0][-1] in vowels

                features["in_table"] = self._tab_hash.has_key(token)

                try:
                        features["1up_2_dot_restok"] = token[0].isupper() and token[1] is "." and token[2] is " " and token[3:].islower()
                except Exception:
                        features["1up_2_dot_restok"] = False
                features["token"] = token
                for vowel in'aeiou':
                        
                        features["count(%s)"%vowel] = token.lower().count(vowel)
                        features["has(%s)"%vowel] = vowel in token
                
                imp = token[0].isupper() and token[1:].islower()
                features["fl_caps_rest_small"] = imp

                if(string_weight > 18):
                        features["Str_Wgt"] = 'A'
                elif(string_weight >14):
                        features["Str_Wgt"] = 'B'
                elif(string_weight > 9):
                        features["Str_Wgt"] = 'C'
                elif(string_weight > 4):
                        features["Str_Wgt"] = 'D'
                else:
                        features["Str_Wgt"] = 'F'
                return features
        

        def _buildFeatures(self,labeledData):
                featuresets = [(self.taxon_features(data),label) for (data,label) in labeledData]
                if(self.learning_algo =="NB"):
                        #WNB = nltk.classify.weka.WekaClassifier.train("NB",featuresets,"naivebayes")
                        NB = nltk.NaiveBayesClassifier.train(featuresets)
                        #MaxEnt = nltk.MaxentClassifier.train(featuresets,"iis",max_iter=3)
                        #DT = nltk.DecisionTreeClassifier.train(featuresets)
                        self._model = NB
                

                

        def getModel(self):
                return self._model

class nameFinder():
        def __init__(self,modelObject,e_list=None):
                reml = {}
                if(e_list is None):
                        e_list = "Nnewlist.txt"
                elist = open(e_list).read().split("\n")
                for a in elist:
                        reml[a] = 1
                self._remlist = reml
                self._modelObject = modelObject
        def _remDot(self,a):
                if(a[-1] == '.' and len(a) > 2 ):
                        return(a[:-1])
                else:
                        return (a)
        def _hCheck(self,a):
                a = self._remDot(a)
                e1 = a.split("-")
                j = [self._remlist.has_key(w) for w in e1]
                return(not True in j and not self._remlist.has_key(a.lower()))
        
        def _isGood2(self,a,b):
                if(len(a) >1 and len(b) >1):
                        td = (a[1] == '.' and len(a) ==2)
                        s1 = a[0].isupper() and b.islower() and ((a[1:].islower() and a.isalpha()) or td) and (self._remDot(b).isalpha() or '-' in b)
                        return(s1 and self._hCheck(a) and self._hCheck(b))
                else:
                        return(False)
        def _isGood3(self,a,b,c):
                if(len(c) >1):
                        s1 = c.islower() and self._remDot(c).isalpha() and b[-1]!='.'
                        return(s1 and self._isGood2(a,b) and self._hCheck(c))
                else:
                        return(False)
        def _taxonTest(self,tkn):
                return((self._modelObject.getModel().classify(self._modelObject.taxon_features(tkn)) =='taxon'))

        def _resolve(self,a,b,c,nhash,nms,last_genus,plg):
                gr =self._remDot((a+" "+b+" "+c).strip())
                if(gr[1] =="." and gr[2] ==" "):
                        if(nhash.has_key(gr)):
                                nms.append(self._remDot((a[0]+"["+nhash[gr]+"]"+" "+b+" "+c).strip()))
                        elif(last_genus and a[0] == last_genus[0]):
                                nms.append(self._remDot((a[0]+"["+last_genus[1:]+"]"+" "+b+" "+c).strip()))
                        elif(plg and a[0]==plg):
                                nms.append(self._remDot((a[0]+"["+plg[1:]+"]"+" "+b+" "+c).strip()))
                        else:
                                nms.append(gr)
                else:
                        nms.append(gr)
                        nhash[self._remDot((a[0]+". "+b+" "+c).strip())] = a[1:]
        
        def find_names(self,text,resolvedot = True):
                tok = nltk.word_tokenize(text)
                names = self.findNames(tok)
                sn = set(names)
                lnames = list(sn)
                rnames = []
                nh = {}
                if(resolvedot):
                        abrn = [a for a in lnames if(a[1]=="." and a[2] ==" ")]
                        diff = sn.difference(set(abrn))
                        ld = list(diff)
                        for i in ld:
                                prts = i.split(" ")
                                st = " ".join(prts[1:])
                                nh[i[0]+". "+st] = prts[0][1:]
                        nl = []
                        for n in abrn:
                                if(nh.has_key(n)):
                                        nl.append(n[0]+"["+nh[n]+"]"+" "+n[3:])
                                else:
                                        nl.append(n)
                        resolved_list = nl+ld
                        resolved_list.sort()
                        rnames = resolved_list
                else:
                        lnames.sort()
                        rnames = lnames
                                        
                
                
                return("\n".join(rnames))
        
        def findNames(self,token):
                nms = []
                last_genus = ""
                prev_last_genus=""
                nhash = {}
                ts = time.clock()
                if(len(token) ==2):
                        if(self._isGood2(token[0],token[1]) and self._taxonTest(token[0]+" "+token[1])):
                                nms.append(token[0]+" "+token[1])
                elif(len(token)==1):
                        if(token[0][0].isupper() and token[0].isalpha() and hCheck(token[0]) and len(token[0])>2 and self._taxonTest(token[0])):
                                nms.append(token[0])

                else:
                        tgr = nltk.trigrams(token)
                        #not generating bigrams...getting them from trigrams..little more efficient
                        for a,b,c in tgr:
                                bg = self._remDot(a+" "+b)
                                tg = self._remDot(a+" "+b+" "+c)
                                j = -1
                                count = 0
                                if(nms):
                                        while(abs(j)<=len(nms)):
                                                if(nms[j][1] != "[" and nms[j][1] != "."):
                                                        if(count == 0):
                                                                last_genus = nms[j].split(" ")[0]
                                                                count = count+1
                                                        else:
                                                                prev_last_genus = nms[j].split(" ")[0]
                                                                break
                                                j = j-1
                                if(self._isGood3(a,b,c)):
                                        if(self._taxonTest(tg)):
                                                #nms.append(tg)
                                                self._resolve(a,b,c,nhash,nms,last_genus,prev_last_genus)

                                elif(self._isGood2(a,b)):
                                        if(self._taxonTest(bg)):
                                                #nms.append(bg)
                                                self._resolve(a,b,"",nhash,nms,last_genus,prev_last_genus)
				
				elif(a[0].isupper() and a.isalpha() and self._hCheck(a) and len(a)>2):
                                        if(self._taxonTest(a)):
                                                nms.append(a)
		try:
                        if(self._isGood2(tgr[-1][-2],tgr[-1][-1])):
                                if(self._taxonTest(self._remDot(tgr[-1][-2]+" "+tgr[-1][-1]))):
                                        self._resolve(tgr[-1][-2],tgr[-1][-1],"",nhash,nms,last_genus,prev_last_genus)
                                        #nms.append(self._remDot(tgr[-1][-2]+" "+tgr[-1][-1]))
				elif(tgr[-1][-2][0].isupper() and tgr[-1][-2].isalpha() and self._hCheck(tgr[-1][-2]) and len(tgr[-1][-2]) >2):
                                        if(self._taxonTest(tgr[-1][-2])):
                                                nms.append(tgr[-1][-2])
		except Exception:
                        print ""
		te = time.clock()
		#print (te-ts)
		return(nms)

	def embedNames(lst,filename):
                
                f = open(filename).read()
                sents = nltk.sent_tokenize(f)
                tksents = [nltk.word_tokenize(a) for a in sents]
                #esents = tksents
                for l in lst:
                        i = random.randint(0,len(tksents)-1)
                        tksents[i].insert(random.randint(0,len(tksents[i])-1),l)
                sents = [" ".join(t) for t in tksents]
                etext = " ".join(sents)
                return(etext)


if __name__ == '__main__':
        print "NETI..NETI\n"

        


    
    
    
