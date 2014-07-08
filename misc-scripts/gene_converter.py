import sys, json, time, urllib2
import multiprocessing.dummy
import cPickle as pi

p = multiprocessing.dummy.Pool(3)
server = "http://beta.rest.ensembl.org"

def get_homologue(sym):
    ext = "/homology/symbol/human/{}?".format(sym.strip()) \
            + "target_species=rattus_norvegicus;sequence=none"
    try:
        req = urllib2.Request(url=server+ext, 
                headers={"Content-Type":"application/json"})
        res = urllib2.urlopen(req)
        decode = json.loads(res.read())
        return sym, decode['data'][0]['homologies'][0]['target']['id']
    except:
        try:
            print ext
            print res.info()
            print res.read()
            print res.getcode()
        except:
            pass
        return sym, ''

rat_ens = p.map(get_homologue, human_list)


