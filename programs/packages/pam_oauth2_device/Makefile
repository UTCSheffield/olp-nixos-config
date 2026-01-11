CXXFLAGS=-Wall -fPIC -std=c++11

LDLIBS=-lpam -lcurl -lldap -llber

OBJDIR=build

objects = $(OBJDIR)/pam_oauth2_device.o \
          $(OBJDIR)/include/config.o \
          $(OBJDIR)/include/ldapquery.o \
          $(OBJDIR)/include/nayuki/BitBuffer.o \
          $(OBJDIR)/include/nayuki/QrCode.o \
          $(OBJDIR)/include/nayuki/QrSegment.o

all: pam_oauth2_device.so

$(OBJDIR)/%.o: src/%.cpp src/%.hpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

pam_oauth2_device.so: $(objects)
	$(CXX) -shared $^ $(LDLIBS) -o $@

clean:
	rm -f $(objects)

distclean: clean
	rm -f pam_oauth2_device.so

install: pam_oauth2_device.so
	install -D -t $(DESTDIR)$(PREFIX)/lib/security pam_oauth2_device.so
	install -m 600 -D config_template.json $(DESTDIR)$(PREFIX)/etc/pam_oauth2_device/config.json
