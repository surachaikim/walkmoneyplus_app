import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:walkmoney/palette.dart';
import 'package:walkmoney/screen/memberinfo.dart';
import 'package:walkmoney/service/config.dart';

class SerachnameScreen extends StatefulWidget {
  SerachnameScreenState createState() => SerachnameScreenState();
}

bool Isshow = true;

class SerachnameScreenState extends State<SerachnameScreen> {
  List persons = [];
  List personsdf = [];
  List original = [];
  List aa = [];
  bool searchchk = false;
  String title = 'รายชื่อสมาชิกทั้งหมด';

  TextEditingController txtQuery = new TextEditingController();

  void search(String query) {
    if (original.isEmpty) {
      original = Config.data_member;
    }

    if (query.isEmpty) {
      searchchk = true;
      persons = personsdf;
      setState(() {});
      return;
    } else {
      query = query.toLowerCase();

      List result = [];

      original.forEach((p) {
        var name =
            p["firstName"].toString() +
            " " +
            p["lastName"].toString().toLowerCase();
        if (name.contains(query)) {
          result.add(p);
        }
      });

      persons = result;
      if (persons.isEmpty) {
        searchchk = true;
      } else {
        searchchk = false;
      }
    }

    setState(() {
      title = "ผลการค้นหา";
    });
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  Future getdata() async {
    if (original.isEmpty) {
      if (Config.data_member.isEmpty) {
        refresh();
      } else {
        setState(() {
          Isshow = false;
          original = Config.data_member;
          persons = Config.data_member;
        });
      }
    }
  }

  Future refresh() async {
    setState(() {
      Isshow = true;
    });

    var url = Uri.parse(
      Config.UrlApi + "/api/GetMember?Sys=2&Cusid=" + Config.CusId,
    );

    var headers = {
      'Verify_identity': Config.Verify_identity,
      "Accept": "application/json",
    };
    var response = await http.get(url, headers: headers);
    var json = jsonDecode(response.body);
    setState(() {
      Isshow = false;
      original = json;
      persons = json;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "ค้นหาชื่อสมาชิก",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => refresh(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Palette.kToDark.shade100, Palette.kToDark.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: Column(
              children: [
                _buildSearchBar(),
                _buildTitleBar(),
                Expanded(
                  child:
                      Isshow
                          ? _buildShimmerLoading()
                          : persons.isEmpty
                          ? _buildEmptyState()
                          : Container(
                            color: Colors.white,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: persons.length,
                              separatorBuilder:
                                  (_, __) => Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.grey.shade300,
                                  ),
                              itemBuilder: (context, index) {
                                final person = persons[index];
                                return _buildMemberRow(person);
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: txtQuery,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          search(value);
        },
        onChanged: (value) {
          if (value.isEmpty) {
            setState(() {
              title = 'รายชื่อสมาชิกทั้งหมด';
              persons = original;
            });
          }
        },
        decoration: InputDecoration(
          hintText: "ค้นหาชื่อ-นามสกุล...",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Palette.kToDark.shade200),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Palette.kToDark.shade200, width: 2),
          ),
          suffixIcon:
              txtQuery.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                    onPressed: () {
                      txtQuery.clear();
                      setState(() {
                        title = 'รายชื่อสมาชิกทั้งหมด';
                        persons = original;
                      });
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          if (persons.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${persons.length} คน',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            "ไม่พบสมาชิก",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ลองค้นหาด้วยคำค้นหาอื่น",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberRow(Map person) {
    final title =
        (person['title'] ?? '').toString() +
        (person['firstName'] ?? '').toString() +
        ' ' +
        (person['lastName'] ?? '').toString();
    final idshow = (person['idcardshow'] ?? '').toString();
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => Memberinfo(
                  personid: person['personId'],
                  idcardshow: person['idcardshow'],
                  idcard: person['idcard'],
                  name: title,
                  adress1:
                      person['addrNo'] +
                      ' ม.' +
                      person['moo'] +
                      ' ต.' +
                      person['locality'] +
                      ' อ.' +
                      person['district'] +
                      ' จ.' +
                      person['province'] +
                      ' ' +
                      person['zipCode'],
                  adress2:
                      person['addrNo1'] +
                      ' ม.' +
                      person['moo1'] +
                      ' ต.' +
                      person['locality1'] +
                      ' อ.' +
                      person['district1'] +
                      ' จ.' +
                      person['province1'] +
                      ' ' +
                      person['zipCode1'],
                  phone: person['phone'],
                ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: Colors.black54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    idshow,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  // _buildMemberCard removed in favor of a simple row list with dividers
}
