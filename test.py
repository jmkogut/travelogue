import os
import time


from lexer import Lexer

l = Lexer()


def start(name):
    print('%s %s' % (name, '-'*(60-(len(name)+1))))
    return (name, time.time())

def stop(s):
    o = "%sms" % (int((time.time() - s[1]) * 1000))
    print('%s: %s %s' % (s[0], o, '-'*(60-(len(o)+len(s[0])+1))))

# start timer
s = start('Indexing')
sources = os.listdir('sources')
for file in sources:
    if file.endswith('.txt'):
        print("Indexing [%s/%s]" % (sources.index(file)+1, len(sources)+1))
        l.index('sources/'+file)
    else:
        print("Skipped non-source: %s" % (file))

# Stop timer
stop(s)

print("\n")
s = start('Statistics')
print("\tTokens: %s" % (len(l.tokens)))
print("\tDocuments: %s" % (len(l.documents)))

range = (0,5)

print("\n")
print("Finding %s-%s most seen tokens" % (range[0], range[1]))


l.sort_tokens()


for token in l.sort_order[range[0]:range[1]]:
    print("\t%s\t- %s" % (l.count_token(token[0]), token[0]))
stop(s)
