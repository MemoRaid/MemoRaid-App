import 'package:flutter/material.dart';
import 'dart:async';
// Remove unused import
// import 'dart:math';

// Fix private type in public API
class StoryRecallScreen extends StatefulWidget {
  const StoryRecallScreen({super.key});

  @override
  // Change to public type name
  StoryRecallScreenState createState() => StoryRecallScreenState();
}

// Rename class to remove underscore
class StoryRecallScreenState extends State<StoryRecallScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedStoryIndex = -1;
  bool _readingStory = false;
  bool _showQuestions = false;
  int _currentQuestionIndex = 0;
  Timer? _questionTimer;
  int _remainingQuestionTime = 30; // seconds per question
  int _score = 0;
  List<bool?> _questionResults = [];

  late AnimationController _animationController;

  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'The Family Reunion',
      'author': 'Memory Masters',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '5 min',
      'text':
          'The annual Rodriguez family reunion took place on Saturday, July 15th at Lakeside Park. Grandmother Elena, wearing her signature blue dress with white flowers, arrived first at 11:30 AM with her famous paella. Uncle Carlos and Aunt Maria brought their twins, Lucas and Sofia, who had just turned 7 last month. The twins wore matching green t-shirts with dinosaur prints. Cousin Alejandro, a doctor from Chicago, surprised everyone by bringing his new fiancée, Priya, who works as a software engineer and brought homemade samosas that everyone loved. Elena\'s youngest son, Miguel, arrived late at 2:15 PM after his flight from Boston was delayed—he brought three bottles of wine from his collection: a 2015 Cabernet, a 2018 Chardonnay, and a 2010 Merlot that he\'d been saving for a special occasion. The family sat at three connected rectangular tables covered with yellow tablecloths. Elena sat at the head with Carlos and Maria to her right, and Miguel and his wife Daniela to her left. Alejandro and Priya sat across from the twins, who couldn\'t stop playing with their cousin Isabella\'s golden retriever named Sunny. After lunch, Uncle Roberto told the story about his fishing trip where he caught a 24-pound bass at Lake Murray last spring. The family took a group photo at 4:45 PM under the old oak tree, arranging themselves in three rows—elders seated in front, middle-aged adults in the middle, and seven children standing in the back row making funny faces. Before leaving, they agreed to meet next year at Uncle Roberto\'s beach house in San Diego on July 8th.',
      'questions': [
        {
          'question': 'What color was Elena\'s dress?',
          'options': [
            'Red with white polka dots',
            'Blue with white flowers',
            'Green with yellow stripes',
            'Purple with lace trim'
          ],
          'correctIndex': 1
        },
        {
          'question': 'What profession does Alejandro have?',
          'options': ['Lawyer', 'Engineer', 'Doctor', 'Teacher'],
          'correctIndex': 2
        },
        {
          'question': 'At what time did Miguel arrive at the reunion?',
          'options': ['11:30 AM', '1:45 PM', '2:15 PM', '3:00 PM'],
          'correctIndex': 2
        },
        {
          'question': 'What type of dog did Isabella have?',
          'options': [
            'Poodle',
            'German Shepherd',
            'Golden Retriever',
            'Beagle'
          ],
          'correctIndex': 2
        },
        {
          'question': 'What was the pattern on the twins\' t-shirts?',
          'options': [
            'Cartoon characters',
            'Sports logos',
            'Dinosaurs',
            'Spaceships'
          ],
          'correctIndex': 2
        },
        {
          'question': 'How many bottles of wine did Miguel bring?',
          'options': ['Two', 'Three', 'Four', 'Five'],
          'correctIndex': 1
        },
        {
          'question': 'Where did the family agree to meet next year?',
          'options': [
            'Grandmother Elena\'s house',
            'Lakeside Park',
            'Uncle Roberto\'s beach house',
            'A restaurant'
          ],
          'correctIndex': 2
        },
        {
          'question': 'What dish did Priya bring to the reunion?',
          'options': ['Curry', 'Samosas', 'Biryani', 'Naan'],
          'correctIndex': 1
        }
      ]
    },
    {
      'title': 'The World Traveler',
      'author': 'Global Adventures',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '6 min',
      'text':
          'Sarah Chen\'s three-month journey began in Barcelona on March 12th, where she stayed in a small apartment on Carrer de Mallorca with a red door and a balcony overlooking a busy café. She visited the Sagrada Familia on her second day, taking 43 photos of the colorful stained glass at sunset. After eight days in Spain, she traveled by train to Nice, France, where she met fellow traveler Markus from Germany who was photographing birds with his Canon EOS 90D camera. Together they visited three museums: the Matisse Museum on Tuesday (which had 23 paintings on display), the Marc Chagall National Museum on Thursday (where Sarah bought a blue coffee mug with stars painted on it), and the Museum of Modern and Contemporary Art on Saturday morning. By April 3rd, Sarah had reached Florence, Italy, staying at the Yellow Hostel where she shared a room with Yuki from Japan and Camila from Brazil. In Florence, Sarah fell in love with stracciatella gelato, eating it four times in five days. She visited the Uffizi Gallery wearing her favorite green sundress and white sandals, spending three hours examining Renaissance paintings. On April 17th, she flew to Santorini, Greece, where she rented a white-washed villa in Oia with blue shutters for 89 euros per night. She took a boat tour of the caldera with Captain Nikos on his vessel "Poseidon\'s Dream," spotting two dolphins and a sea turtle. In Athens, Sarah lost her phone in the Monastiraki market but a kind shopkeeper named Dimitri found it and returned it to her hotel. Her journey ended in Istanbul, where she bought five different spices at the Grand Bazaar: saffron, sumac, za\'atar, Aleppo pepper, and a special chai blend. She brought home seven souvenirs, including a hand-painted ceramic plate from Portugal and a small amber necklace from a street vendor in Prague that cost 1,200 koruna.',
      'questions': [
        {
          'question': 'In which city did Sarah begin her journey?',
          'options': ['Madrid', 'Barcelona', 'Paris', 'Lisbon'],
          'correctIndex': 1
        },
        {
          'question': 'What camera was Markus using to photograph birds?',
          'options': [
            'Nikon D850',
            'Sony Alpha',
            'Canon EOS 90D',
            'Fujifilm X-T4'
          ],
          'correctIndex': 2
        },
        {
          'question': 'How many museums did Sarah visit in Nice?',
          'options': ['Two', 'Three', 'Four', 'Five'],
          'correctIndex': 1
        },
        {
          'question': 'What type of gelato did Sarah favor in Florence?',
          'options': ['Pistachio', 'Stracciatella', 'Chocolate', 'Lemon'],
          'correctIndex': 1
        },
        {
          'question': 'How much was Sarah\'s villa in Santorini per night?',
          'options': ['69 euros', '79 euros', '89 euros', '99 euros'],
          'correctIndex': 2
        },
        {
          'question': 'What was the name of Captain Nikos\'s boat?',
          'options': [
            'Aegean Dream',
            'Blue Horizon',
            'Poseidon\'s Dream',
            'Mediterranean Star'
          ],
          'correctIndex': 2
        },
        {
          'question':
              'Which of these spices did Sarah NOT buy at the Grand Bazaar?',
          'options': ['Saffron', 'Cumin', 'Za\'atar', 'Aleppo pepper'],
          'correctIndex': 1
        },
        {
          'question': 'From which city did Sarah get an amber necklace?',
          'options': ['Istanbul', 'Athens', 'Prague', 'Vienna'],
          'correctIndex': 2
        }
      ]
    },
    {
      'title': 'The Mansion Mystery',
      'author': 'Puzzle Masters',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '7 min',
      // Fix the string escaping in this text - this was causing errors
      'text':
          'Detective Morgan Wright arrived at Raven Manor at 9:15 PM on a stormy Tuesday night. The sprawling mansion belonged to retired industrialist Harold Blackwood, who was found dead in his study at approximately 7:30 PM by his butler, Jenkins. The study was located on the second floor, third door on the left from the grand staircase, with mahogany double doors featuring brass handles shaped like lions\' heads. Inside, Blackwood\'s body was slumped over his antique rosewood desk facing the east window. He still held a fountain pen with blue ink in his right hand. A half-empty glass of 18-year-old Macallan whiskey sat on his right side, and a leather-bound appointment book lay open to October 23rd. Detective Wright interviewed five people who were present at the mansion that evening. The victim\'s niece, Victoria Parker (wearing a burgundy dress with pearl earrings), claimed she was in the conservatory playing Chopin\'s Nocturne No. 2 on the grand piano at the time of death. Charles Blackwood, the victim\'s younger brother, said he was in the billiard room practicing for a tournament and mentioned hearing a loud argument from the study around 7:15 PM. Family lawyer Richard Stephens (with a gray mustache and tortoiseshell glasses) stated he arrived at 6:45 PM to discuss changes to Harold\'s will, which would have reduced Victoria\'s inheritance from 60% to 25% of the estate. The chef, Marcella Rossi, confirmed preparing Harold\'s usual Tuesday dinner—beef Wellington, asparagus with hollandaise sauce, and raspberry tart—which was delivered to the study by Jenkins at 6:30 PM. Jenkins, who had worked for the family for 27 years, noted that Harold received a phone call at 7:10 PM that left him agitated. Crime scene investigators found a crumpled note in the fireplace with partially burned text reading "...know what you did with the company funds...meet or I will expose...". The medical examiner, Dr. Abigail Chen, noted symptoms consistent with cyanide poisoning, including a faint almond smell on the victim\'s lips. Detective Wright noticed the whiskey bottle on the bar cart had been recently opened, as the seal was broken but the bottle was still 90% full.',
      'questions': [
        {
          'question': 'At what time was Harold Blackwood found dead?',
          'options': ['7:15 PM', '7:30 PM', '8:45 PM', '9:15 PM'],
          'correctIndex': 1
        },
        {
          'question': 'What was Victoria Parker wearing?',
          'options': [
            'Black dress with gold jewelry',
            'Burgundy dress with pearl earrings',
            'Navy suit with silver brooch',
            'Green gown with diamond necklace'
          ],
          'correctIndex': 1
        },
        {
          'question': 'What piece of music was Victoria playing?',
          'options': [
            'Mozart\'s Sonata',
            'Bach\'s Fugue',
            'Beethoven\'s Symphony',
            'Chopin\'s Nocturne'
          ],
          'correctIndex': 3
        },
        {
          'question': 'What was the main course of Harold\'s Tuesday dinner?',
          'options': [
            'Roast chicken',
            'Beef Wellington',
            'Salmon fillet',
            'Lamb chops'
          ],
          'correctIndex': 1
        },
        {
          'question':
              'Which door in the sequence from the staircase was the study?',
          'options': ['Second door', 'Third door', 'Fourth door', 'Fifth door'],
          'correctIndex': 1
        },
        {
          'question':
              'What percentage would Victoria\'s inheritance have been reduced to?',
          'options': ['15%', '25%', '35%', '45%'],
          'correctIndex': 1
        },
        {
          'question': 'How many years had Jenkins worked for the family?',
          'options': ['17 years', '22 years', '27 years', '32 years'],
          'correctIndex': 2
        },
        {
          'question': 'What shape were the brass handles on the study doors?',
          'options': ['Eagles', 'Dragons', 'Lions', 'Wolves'],
          'correctIndex': 2
        }
      ]
    },
    {
      'title': 'The Startup Challenge',
      'author': 'Business Minds',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '6 min',
      'text':
          'GreenLife Technologies\' founding team met at Stanford University\'s entrepreneurship program in 2018. CEO Emily Chen had previously worked at Tesla for 3.5 years in battery technology. CTO Marcus Williams held 4 patents in sustainable engineering and had a Ph.D. from MIT. CMO Sophia Rodriguez had grown her previous company\'s customer base from 5,000 to 135,000 users in 18 months before joining GreenLife. Their smart home energy management system consisted of three components: the Hub (priced at \$249), multiple Sensors (\$49 each), and the EcoSave app with both free and premium subscription tiers (\$7.99/month). Their Series A pitch on March 17th to Sequoia Ventures took place in a conference room named "Redwood" on the 14th floor. Emily wore a navy blue blazer over a white silk blouse, Marcus chose a gray sweater with black jeans, and Sophia dressed in a forest green pantsuit. The team presented 27 slides showing their technology could reduce home energy consumption by 28-34%. Their proprietary algorithm, developed over 16 months, analyzed usage patterns across 7 categories of household appliances. Market analysis identified their target demographics as environmentally-conscious millennials aged 28-42 and upper-middle-class homeowners in suburban areas, with an estimated total addressable market of \$4.3 billion. Early beta testing involved 142 households across 5 states, with users reporting average monthly savings of \$42-68 on utility bills. Venture capitalist Kathryn Nguyen asked 8 questions during the Q&A, focusing particularly on their customer acquisition strategy and unit economics. Fellow investor David Park expressed concerns about their 18-month runway and suggested they might need \$3.2 million instead of their requested \$2.8 million to achieve sustainable growth. The founders had already invested \$180,000 of their own money and secured a \$250,000 angel investment from former Google executive Thomas Reed. Their 5-year projection showed profitability by year 3, with projected annual recurring revenue of \$14.5 million. After deliberation, Sequoia offered \$3 million at a \$15 million valuation with a 20% equity stake, contingent on the team hiring a seasoned COO within 60 days.',
      'questions': [
        {
          'question': 'How many patents did the CTO hold?',
          'options': ['2 patents', '3 patents', '4 patents', '5 patents'],
          'correctIndex': 2
        },
        {
          'question': 'What color blazer did Emily wear to the pitch?',
          'options': ['Black', 'Gray', 'Navy blue', 'Red'],
          'correctIndex': 2
        },
        {
          'question':
              'What was the name of the conference room where the pitch took place?',
          'options': ['Sequoia', 'Redwood', 'Venture', 'Stanford'],
          'correctIndex': 1
        },
        {
          'question': 'How many slides did the team present?',
          'options': ['17 slides', '22 slides', '27 slides', '32 slides'],
          'correctIndex': 2
        },
        {
          'question': 'What was the monthly cost of the premium subscription?',
          'options': ['4.99', '6.99', '7.99', '9.99'],
          'correctIndex': 2
        },
        {
          'question': 'How many households participated in beta testing?',
          'options': [
            '98 households',
            '117 households',
            '142 households',
            '163 households'
          ],
          'correctIndex': 2
        },
        {
          'question': 'What amount of funding did the team originally request?',
          'options': [
            '2.2 million',
            '2.5 million',
            '2.8 million',
            '3.0 million'
          ],
          'correctIndex': 2
        },
        {
          'question': 'By which year did the team project profitability?',
          'options': ['Year 2', 'Year 3', 'Year 4', 'Year 5'],
          'correctIndex': 1
        }
      ]
    },
    {
      'title': 'The Battle of Rivers Crossing',
      'author': 'Historical Chronicles',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '7 min',
      'text':
          'The decisive Battle of Rivers Crossing began at dawn on September 18, 1862, with fog covering the valley between Pine Ridge and Oak Hill. General Thomas Fletcher commanded the Northern forces with 13,500 infantry divided into three divisions: the 4th Regiment (wearing dark blue uniforms with brass buttons) led by Colonel James Harrington on the right flank, the 7th Regiment (identified by their distinctive red shoulder patches) under Colonel William Stone in the center, and the 2nd Regiment led by the young but brilliant Colonel Robert Hayes on the left flank. The Southern forces, numbering approximately 11,800 men under General Edward Thornton, took defensive positions along Oak Hill, placing 12 artillery pieces on the high ground—9 twelve-pound howitzers and 3 larger twenty-four pound cannons. The battle commenced at 6:45 AM when the Northern artillery fired 37 rounds at the Southern positions. Colonel Hayes led the first assault at 7:30 AM with 2,300 men crossing Willow Creek, but was repelled after losing 340 soldiers in 25 minutes. By midday, the temperature had reached 84 degrees, and many soldiers suffered from heat exhaustion while wearing their heavy wool uniforms. The tide turned at 2:15 PM when Colonel Harrington discovered an unguarded path through Maple Woods that allowed his forces to outflank the Southern right position. General Thornton, realizing the danger, ordered his reserve cavalry unit of 750 riders under Major Jonathan Pierce to counterattack, resulting in fierce hand-to-hand combat near Farmer Phillips\' wheat field. The battle\'s crucial moment came at 4:05 PM when Colonel Stone\'s men charged across the stone bridge spanning Rivers Creek, suffering 422 casualties but successfully breaking through the Southern center. By sunset at 6:24 PM, Southern forces retreated to Lancaster Ridge, having lost 2,850 men compared to the Northern forces\' 1,725 casualties. Among the fallen was Colonel William Stone, who was struck by a musket ball at 3:47 PM while rallying his men and died at a field hospital two hours later. The battle ended with the Northern capture of Oak Hill and 5 enemy artillery pieces. President Lincoln promoted General Fletcher to Major General five days later, and the battlefield became a national monument in 1894, with a 17-foot marble obelisk marking the spot where Colonel Stone fell.',
      'questions': [
        {
          'question': 'On what date did the Battle of Rivers Crossing occur?',
          'options': [
            'August 12, 1862',
            'September 18, 1862',
            'October 23, 1862',
            'November 7, 1862'
          ],
          'correctIndex': 1
        },
        {
          'question': 'How many infantry did General Fletcher command?',
          'options': ['11,800 men', '12,700 men', '13,500 men', '14,200 men'],
          'correctIndex': 2
        },
        {
          'question': 'Which regiment was identified by red shoulder patches?',
          'options': [
            '2nd Regiment',
            '4th Regiment',
            '7th Regiment',
            '9th Regiment'
          ],
          'correctIndex': 2
        },
        {
          'question': 'How many artillery pieces did the Southern forces have?',
          'options': ['8 pieces', '10 pieces', '12 pieces', '14 pieces'],
          'correctIndex': 2
        },
        {
          'question': 'At what time did the first Northern assault begin?',
          'options': ['6:45 AM', '7:30 AM', '8:15 AM', '9:00 AM'],
          'correctIndex': 1
        },
        {
          'question':
              'How many casualties did the Northern forces suffer in total?',
          'options': ['1,240 men', '1,725 men', '2,150 men', '2,675 men'],
          'correctIndex': 1
        },
        {
          'question': 'Which colonel died during the battle?',
          'options': [
            'Colonel Hayes',
            'Colonel Harrington',
            'Colonel Stone',
            'Colonel Pierce'
          ],
          'correctIndex': 2
        },
        {
          'question':
              'How tall was the marble obelisk marking Colonel Stone\'s fall?',
          'options': ['15 feet', '17 feet', '20 feet', '23 feet'],
          'correctIndex': 1
        }
      ]
    },
    {
      'title': 'The Medical Breakthrough',
      'author': 'Scientific Records',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '7 min',
      'text':
          'On February 13, 2021, research team Gamma-7 at Northwell Institute achieved a breakthrough in targeted immunotherapy. Lead scientist Dr. Amelia Zhang, who earned her PhD from Johns Hopkins in 2009, headed the team of 11 researchers who had been working on Project Nexus since March 2017. Their novel compound, RXT-459, demonstrated an efficacy rate of 78.3% in phase II clinical trials involving 342 patients across 17 medical centers. The compound works by binding to the TRK-742 receptor found on cancer cells, with initial binding occurring at approximately 47 seconds after administration. The most promising results were seen in patients with stage III lymphoma, where tumor reduction averaged 63.8% after 8 weeks of treatment (compared to 27.2% with standard protocols). The research was funded by a \$14.7 million grant from the National Institute of Health (grant #NIH-8842-C7) and received FDA fast-track designation on January 24, 2021. The team utilized a specialized mass spectrometer (model QE-470) operating at -192°C to isolate the compound structure, which contains 28 carbon atoms arranged in a distinctive hexagonal pattern. Side effects were minimal, with only 5.3% of patients reporting grade 3 or higher adverse events, significantly lower than the 23.1% observed with existing treatments. Dr. Zhang presented these findings at the International Oncology Conference in Vienna on March 2, 2021, where her 42-slide presentation was delivered to an audience of 517 specialists. The institute filed patents (US20210157-A and EU459322) on the compound and its synthesis process, which requires exactly 14 steps and maintains stability for 174 days at room temperature. The breakthrough could potentially benefit an estimated 225,000 patients annually worldwide, with projected treatment costs of \$7,650 per patient for a complete 12-week regimen. Clinical director Dr. Nathan Rodriguez oversaw the data analysis using the proprietary HELIOS statistical software platform (version 9.3.1), which processed 17.4 terabytes of patient data.',
      'questions': [
        {
          'question':
              'What was the efficacy rate of RXT-459 in phase II clinical trials?',
          'options': ['67.5%', '78.3%', '84.9%', '91.2%'],
          'correctIndex': 1
        },
        {
          'question': 'How many patients participated in the clinical trials?',
          'options': [
            '225 patients',
            '342 patients',
            '457 patients',
            '517 patients'
          ],
          'correctIndex': 1
        },
        {
          'question': 'How many carbon atoms are in the compound structure?',
          'options': ['14 atoms', '17 atoms', '28 atoms', '42 atoms'],
          'correctIndex': 2
        },
        {
          'question': 'At what temperature did the mass spectrometer operate?',
          'options': ['-86°C', '-127°C', '-192°C', '-273°C'],
          'correctIndex': 2
        },
        {
          'question':
              'What percentage of patients reported grade 3 or higher adverse events?',
          'options': ['2.7%', '5.3%', '8.6%', '12.1%'],
          'correctIndex': 1
        },
        {
          'question': 'What was the US patent number for the compound?',
          'options': [
            'US20190157-A',
            'US20200157-A',
            'US20210157-A',
            'US20220157-A'
          ],
          'correctIndex': 2
        },
        {
          'question': 'How many steps are required in the synthesis process?',
          'options': ['8 steps', '11 steps', '14 steps', '17 steps'],
          'correctIndex': 2
        },
        {
          'question': 'What is the projected treatment cost per patient?',
          'options': ['\$5,420', '\$7,650', '\$9,875', '\$12,340'],
          'correctIndex': 1
        }
      ]
    },
    {
      'title': 'The Art Heist Investigation',
      'author': 'Criminal Archives',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '6 min',
      'text':
          'The Metropolitan Museum of Art heist occurred on October 17, 2022, with four paintings valued at \$127.3 million stolen between 2:14 AM and 2:38 AM. Detective Sophia Reynolds (badge #8294) was assigned as lead investigator, arriving on scene at 3:07 AM. Security footage revealed that the museum\'s state-of-the-art alarm system (model SP-5000) had been disabled using a sophisticated electromagnetic device. Three perpetrators were identified from partial footage: a tall figure (approximately 6\'2") wearing a black mask designated as "Subject A," a medium-build person wearing specialized climbing equipment (designated "Subject B"), and a tech specialist carrying a customized laptop with the IP address 192.168.43.176 (designated "Subject C"). The stolen artwork included Van Gogh\'s "Autumn Twilight" (painted in 1889, valued at \$42.8 million), Monet\'s "Harbor at Dawn" (1873, valued at \$38.5 million), a rare Vermeer sketch (1665, valued at \$24.7 million), and Cézanne\'s "Mountain Vista" (1902, valued at \$21.3 million). Forensics recovered 14 partial fingerprints and 3 DNA samples, one matching ex-security guard Thomas Wilson who had been terminated from the museum 67 days before the heist. GPS data from a recovered burner phone showed movement patterns between five locations: a warehouse at 4723 Riverside Dr, an apartment at 189 West 53rd St (Apt 7B), a storage facility in Queens (unit #E429), a marina with 37 boat slips, and a private airfield handling approximately 43 flights weekly. Insurance investigators calculated that the thieves spent exactly 24 minutes inside the museum and disabled 7 separate security features. Detective Reynolds discovered that the museum had recently upgraded its security protocol on September 29, but the manual override codes (6-digit sequence beginning with 724) had not been changed in 38 months. A breakthrough came when trace analysis found distinctive particles of Rhodium catalytic converter material (worth \$18,500 per ounce) on the museum floor, matching a custom Bentley Continental (license plate RHD-835) seen four times near the museum in the week preceding the theft. The FBI assigned 17 agents to the case under operation code "Painter\'s Shadow" with case number FB-22-73485.',
      'questions': [
        {
          'question': 'What was the total value of the stolen artwork?',
          'options': [
            '\$98.7 million',
            '\$112.5 million',
            '\$127.3 million',
            '\$143.6 million'
          ],
          'correctIndex': 2
        },
        {
          'question': 'What was Detective Reynolds\' badge number?',
          'options': ['#7192', '#8294', '#9317', '#6438'],
          'correctIndex': 1
        },
        {
          'question':
              'How many separate security features did the thieves disable?',
          'options': ['5 features', '7 features', '9 features', '11 features'],
          'correctIndex': 1
        },
        {
          'question': 'What was the license plate of the Bentley Continental?',
          'options': ['RHD-835', 'HDR-538', 'RDH-385', 'DHR-853'],
          'correctIndex': 0
        },
        {
          'question': 'When was Van Gogh\'s "Autumn Twilight" painted?',
          'options': ['1873', '1889', '1902', '1934'],
          'correctIndex': 1
        },
        {
          'question':
              'How many boat slips were at the marina identified in the investigation?',
          'options': ['24 slips', '37 slips', '42 slips', '58 slips'],
          'correctIndex': 1
        },
        {
          'question':
              'What was the IP address found on the tech specialist\'s laptop?',
          'options': [
            '192.168.37.145',
            '192.168.43.176',
            '192.168.52.193',
            '192.168.67.211'
          ],
          'correctIndex': 1
        },
        {
          'question':
              'How many days before the heist was Thomas Wilson terminated?',
          'options': ['52 days', '67 days', '78 days', '91 days'],
          'correctIndex': 1
        }
      ]
    },
    {
      'title': 'Corporate Merger Analysis',
      'author': 'Business Journal',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '8 min',
      'text':
          'On June 30, 2023, Vertex Technologies announced its acquisition of Quantum Dynamics for \$8.7 billion (\$142.50 per share, representing a 28.4% premium over the previous 30-day average). The deal was brokered by investment bank Morgan Stanley, earning a \$47.3 million advisory fee. Vertex CEO Sarah Chen (age 47) engineered the deal after 3 failed attempts dating back to March 2021, when initial offerings stood at just \$67.25 per share. Quantum\'s proprietary neural network technology (codenamed "BlueShift") had been under development for 7.5 years, consuming \$324.6 million in R&D costs and producing 187 patents. The combined entity would control approximately 34.8% of the quantum computing market, raising antitrust concerns from the Federal Trade Commission. Regulatory filings revealed that Quantum\'s Q1 2023 earnings had exceeded analyst expectations by 17.3%, with revenues of \$892.5 million and operating margins of 32.4%. Vertex planned to integrate Quantum\'s 1,724 employees across 9 global offices, though analysts projected 241 redundancies primarily in administrative roles (saving approximately \$37.2 million annually). The merger financing included \$5.2 billion in cash, an issuance of 26.3 million new Vertex shares, and \$1.8 billion in 5-year convertible bonds at 3.75% interest rate. Vertex\'s stock (NASDAQ: VRTX) initially dropped 4.7% on announcement before rebounding 6.2% after the conference call hosted by CFO Michael Wong at 2:30 PM EST. During the call, Wong outlined expected synergies of \$412 million within 24 months and projected combined revenues of \$14.3 billion by FY2025. The merger required approval from 9 different regulatory bodies across 4 continents, with the European Commission\'s 143-page preliminary assessment raising concerns about data sovereignty over Quantum\'s 17.3 petabytes of customer data stored across 5 regional clouds. The combined entity would operate 14 research centers employing 3,875 scientists and engineers, with the flagship facility in Cambridge housing 72 quantum processors operating at 11.7 kelvin. Integration planning was assigned to consulting firm McKinsey for a \$23.4 million contract over 18 months, with 47 consultants embedded across key departments.',
      'questions': [
        {
          'question':
              'What was the acquisition price per share for Quantum Dynamics?',
          'options': ['\$112.75', '\$127.80', '\$142.50', '\$156.25'],
          'correctIndex': 2
        },
        {
          'question':
              'How many patents did Quantum\'s neural network technology produce?',
          'options': [
            '143 patents',
            '165 patents',
            '187 patents',
            '204 patents'
          ],
          'correctIndex': 2
        },
        {
          'question': 'What was Quantum\'s operating margin in Q1 2023?',
          'options': ['27.6%', '32.4%', '36.8%', '40.2%'],
          'correctIndex': 1
        },
        {
          'question': 'How many employees did Quantum Dynamics have?',
          'options': [
            '1,251 employees',
            '1,493 employees',
            '1,724 employees',
            '1,897 employees'
          ],
          'correctIndex': 2
        },
        {
          'question':
              'How many new Vertex shares were issued as part of the financing?',
          'options': [
            '19.7 million',
            '26.3 million',
            '32.8 million',
            '37.5 million'
          ],
          'correctIndex': 1
        },
        {
          'question': 'What was the interest rate on the convertible bonds?',
          'options': ['2.75%', '3.25%', '3.75%', '4.25%'],
          'correctIndex': 2
        },
        {
          'question': 'How many petabytes of customer data did Quantum have?',
          'options': [
            '12.9 petabytes',
            '15.6 petabytes',
            '17.3 petabytes',
            '19.7 petabytes'
          ],
          'correctIndex': 2
        },
        {
          'question': 'At what temperature did Quantum\'s processors operate?',
          'options': ['4.2 kelvin', '7.8 kelvin', '11.7 kelvin', '15.3 kelvin'],
          'correctIndex': 2
        }
      ]
    },
    {
      'title': 'Arctic Expedition Crisis',
      'author': 'Adventure Chronicle',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '7 min',
      'text':
          'The Polaris Arctic Research Expedition departed from Tromsø, Norway on January 8, 2023, led by Dr. Marcus Eriksson (52), a veteran with 14 prior polar expeditions. The team of 9 scientists traveled aboard the ice-strengthened vessel RV Svalbard (built 2017, 85 meters length, 3,450-ton displacement). Their mission was to collect core samples from the Nordenskiöld Glacier at coordinates 79°43′N 22°24′E, where ice thickness had decreased 37.8% since measurements began in 1986. The team established their primary research station (designated Alpha Base) at an elevation of 347 meters above sea level on January 19th, with temperatures averaging -32°C. Their equipment included 3 specialized drilling rigs (model CryoDrill TX-7), 14 autonomous sensor arrays, and the prototype ArcticRover vehicle valued at \$4.3 million. On February 3rd at 17:42 local time, meteorologist Dr. Sophia Kim detected a rapidly forming polar low pressure system with barometric readings dropping from 1003 hPa to 967 hPa within 6 hours. Wind speeds increased to 127 km/h, forcing the team to engage emergency protocol Delta-7. Communications specialist Jason Torres sent hourly status updates until satellite connection failed at 02:17 on February 4th. With their primary generator malfunctioning, the team switched to backup power with 147 hours of fuel capacity. The RV Svalbard, positioned 73 kilometers from the research station, attempted a rescue but was halted by ice floes measuring 2.8 meters thick. Relief coordination was established at Longyearbyen base (Spitsbergen) with 5 nations contributing resources. The Norwegian Coast Guard deployed the icebreaker KV Svalbard with 24 crew members and 3 rescue helicopters (model AW101) with operational ceiling of 4,575 meters. After 84 hours in emergency conditions, geologist Dr. Elena Petrova identified a subsurface ice cave providing shelter and maintaining a stable -8°C environment. The team rationed remaining supplies: 14.5 liters of fresh water, 23 ready-to-eat meal packs, and medical supplies including 7 morphine injections and 12 units of blood plasma. On February 8th at 14:23, a Finnish specialized SA-330 Puma helicopter (tail number OH-HVK) with modified fuel capacity successfully reached the team, evacuating in two groups across a 36-minute window during a brief clearing in the storm. All 9 scientists survived, though expedition leader Eriksson suffered stage 2 frostbite on three fingers and chief biologist Dr. Alan Wong was treated for hypothermia with core body temperature recorded at 34.2°C upon rescue.',
      'questions': [
        {
          'question': 'What were the coordinates of the Nordenskiöld Glacier?',
          'options': [
            '77°19′N 18°43′E',
            '78°31′N 20°16′E',
            '79°43′N 22°24′E',
            '80°57′N 24°52′E'
          ],
          'correctIndex': 2
        },
        {
          'question':
              'How much had the glacier\'s ice thickness decreased since measurements began?',
          'options': ['26.4%', '32.1%', '37.8%', '43.5%'],
          'correctIndex': 2
        },
        {
          'question': 'What was the elevation of Alpha Base?',
          'options': ['235 meters', '347 meters', '452 meters', '569 meters'],
          'correctIndex': 1
        },
        {
          'question': 'What time did satellite communications fail?',
          'options': ['23:48', '00:31', '02:17', '03:42'],
          'correctIndex': 2
        },
        {
          'question':
              'How thick were the ice floes that stopped the RV Svalbard?',
          'options': ['1.9 meters', '2.8 meters', '3.5 meters', '4.2 meters'],
          'correctIndex': 1
        },
        {
          'question':
              'What was the operational ceiling of the rescue helicopters?',
          'options': [
            '3,250 meters',
            '3,925 meters',
            '4,575 meters',
            '5,100 meters'
          ],
          'correctIndex': 2
        },
        {
          'question':
              'What was Dr. Wong\'s core body temperature when rescued?',
          'options': ['33.5°C', '34.2°C', '35.1°C', '35.7°C'],
          'correctIndex': 1
        },
        {
          'question':
              'How many ready-to-eat meal packs did the team have when stranded?',
          'options': ['17 packs', '23 packs', '28 packs', '34 packs'],
          'correctIndex': 1
        }
      ]
    },
    {
      'title': 'The Mars Mission Anomaly',
      'author': 'Space Chronicles',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '6 min',
      'text':
          'Ares 4, humanity\'s first crewed Mars mission, launched from Kennedy Space Center on September 17, 2037. The spacecraft consisted of the command module Olympus and lander Phobos, powered by 4 Helios-class nuclear thermal propulsion engines generating 7.8 million newtons of thrust. Commander Diana Chen led a crew of 6 international astronauts selected from 7,431 applicants after completing 14,700 hours of training. The spacecraft carried 27 scientific experiments and 4 autonomous rovers. On Sol 72 of the mission (January 19, 2038), at 15:43 UTC, as the craft was 147.8 million kilometers from Earth, astronauts detected radiation fluctuations in sectors 3 and 5 of the habitation ring. Flight Engineer Mikhail Sokolov identified the source as panel array P-117 where radiation levels had increased from 0.23 mSv/hour to 2.87 mSv/hour. Houston calculated total exposure would reach critical levels of 650 mSv after 227 hours, prompting Mission Control Director Dr. James Wilson to order immediate countermeasures. The crew initiated repair protocol Gamma-6, requiring extravehicular activity (EVA) in deep space. Specialists Sarah Nakamura and Omar Al-Farsi prepared for the EVA with suit pressure at 4.73 psi, while Commander Chen and Medical Officer Dr. Thomas Weber reconfigured life support to create a sealed safe zone in module C, maintaining oxygen levels at 23.1% and CO2 below 0.4%. Data analysis by Science Officer Dr. André Laurent revealed 14 similar radiation anomalies had been recorded on unmanned missions, but never exceeding 1.78 mSv/hour. The EVA began at 08:27 UTC on January 20, with the astronauts facing temperature extremes from -157°C in shadow to +121°C in direct sunlight. Communication delays reached 8 minutes and 37 seconds each way, forcing the crew to work autonomously using the HERMES AI assistant (version 5.4.2). After locating the compromised shielding, they deployed 5 radiation dampening patches (each 45×45 cm) using 37 specialized titanium bolts torqued to exactly 24 Newton-meters. Radiation levels stabilized at 0.19 mSv/hour after the 4-hour, 53-minute EVA. The mission proceeded to achieve successful Mars orbit insertion on February 28, 2038, entering a 347 km × 472 km elliptical orbit traveling at 3.7 km/second relative to the Martian surface. The incident required replanning 23% of mission objectives and reallocating 87 kg of reserve shielding material, but the landing at Arcadia Planitia (coordinates 46.7°N, 156.4°W) occurred as scheduled on March 14, 2038.',
      'questions': [
        {
          'question': 'How many astronauts were on the Ares 4 mission?',
          'options': [
            '4 astronauts',
            '5 astronauts',
            '6 astronauts',
            '7 astronauts'
          ],
          'correctIndex': 2
        },
        {
          'question':
              'What was the elevated radiation level detected in panel array P-117?',
          'options': [
            '1.92 mSv/hour',
            '2.35 mSv/hour',
            '2.87 mSv/hour',
            '3.41 mSv/hour'
          ],
          'correctIndex': 2
        },
        {
          'question':
              'How far was the spacecraft from Earth when the anomaly was detected?',
          'options': [
            '104.3 million km',
            '127.5 million km',
            '147.8 million km',
            '165.2 million km'
          ],
          'correctIndex': 2
        },
        {
          'question': 'What was the pressure setting for the EVA suits?',
          'options': ['3.87 psi', '4.29 psi', '4.73 psi', '5.12 psi'],
          'correctIndex': 2
        },
        {
          'question':
              'How many radiation dampening patches were deployed during the EVA?',
          'options': ['3 patches', '5 patches', '7 patches', '9 patches'],
          'correctIndex': 1
        },
        {
          'question':
              'What was the duration of the EVA to repair the radiation shielding?',
          'options': [
            '3 hours, 28 minutes',
            '4 hours, 53 minutes',
            '5 hours, 17 minutes',
            '6 hours, 42 minutes'
          ],
          'correctIndex': 1
        },
        {
          'question':
              'What was the orbital velocity relative to Mars after insertion?',
          'options': [
            '2.9 km/second',
            '3.3 km/second',
            '3.7 km/second',
            '4.2 km/second'
          ],
          'correctIndex': 2
        },
        {
          'question': 'At what coordinates did the landing on Mars occur?',
          'options': [
            '42.3°N, 147.8°W',
            '46.7°N, 156.4°W',
            '51.2°N, 163.7°W',
            '55.9°N, 171.2°W'
          ],
          'correctIndex': 1
        }
      ]
    },
    {
      'title': 'The Rainforest Expedition',
      'author': 'Environmental Journal',
      'coverImage': 'lib/assets/images/story.png',
      'duration': '7 min',
      'text':
          'The Amazon Canopy Research Expedition departed from Manaus, Brazil on April 12, 2022, led by Dr. Elena Rodriguez from the Global Biodiversity Institute. Her team of 8 scientists included botanists, entomologists, and conservation specialists from 6 different countries. Their mission was to document undiscovered species in the upper canopy region between coordinates 3°27\'S 62°51\'W, an area spanning approximately 1,450 hectares of primary rainforest. The expedition established its base camp 37 kilometers from the nearest village, Novo Horizonte, and constructed 5 observation platforms at heights ranging from 27 to 42 meters above the forest floor. Their equipment included 14 specialized camera traps (model CT-XL9) with infrared sensors capable of detecting movement within a 24-meter radius, 8 atmospheric monitoring stations, and the prototype CanopyGlider drone system weighing just 1.2 kilograms but capable of carrying sampling instruments up to 3.4 kilograms. On day 7 of the expedition, at approximately 05:43 local time, Dr. Thomas Nakamura captured the first video evidence of the elusive golden-crested tree frog (Hylidae luminosa), a species previously only documented in a single photograph from 1976. The specimen measured 4.7 centimeters and displayed the characteristic iridescent marking pattern with 12-14 distinct spots. Two days later, the team documented a previously unknown interaction between 35-40 scarlet macaws (Ara macao) and 3 harpy eagles (Harpia harpyja) at an elevation of 38 meters. Senior botanist Dr. Maria Öberg collected samples from 143 different plant species, including 7 previously undocumented varieties of epiphytes (plants growing on other plants). Humidity readings during the expedition averaged 91% with temperatures ranging from 24°C at night to 35°C during midday. The research team\'s most significant discovery came on April 29th when they identified a new species of giant orchid (Orchidaceae gigantus) with a bloom measuring 37 centimeters across, bearing purple-black petals with precisely 42 luminescent spots that glow for 7-9 hours after sunset. The expedition faced a crisis on May 3rd when a sudden thunderstorm with wind speeds reaching 84 km/h damaged equipment platform Charlie-3, requiring emergency repairs using 27 meters of carbon fiber reinforcement material. Despite these challenges, the team collected 1,642 distinct data points across 17 research parameters, surpassing their initial goal by 37%. The findings were published in 4 scientific journals and presented at the International Biodiversity Conference in Geneva on September 14, 2022.',
      'questions': [
        {
          'question':
              'How many scientists were on the Amazon Canopy Research Expedition?',
          'options': [
            '6 scientists',
            '7 scientists',
            '8 scientists',
            '9 scientists'
          ],
          'correctIndex': 2
        },
        {
          'question':
              'At what height were the observation platforms constructed?',
          'options': [
            '17-25 meters',
            '27-42 meters',
            '44-56 meters',
            '62-75 meters'
          ],
          'correctIndex': 1
        },
        {
          'question': 'How many different plant species did Dr. Öberg collect?',
          'options': [
            '117 species',
            '143 species',
            '156 species',
            '178 species'
          ],
          'correctIndex': 1
        },
        {
          'question': 'What was the size of the newly discovered orchid bloom?',
          'options': [
            '28 centimeters',
            '37 centimeters',
            '42 centimeters',
            '51 centimeters'
          ],
          'correctIndex': 1
        },
        {
          'question':
              'When was the expedition\'s finding presented at the conference?',
          'options': [
            'August 27, 2022',
            'September 14, 2022',
            'October 3, 2022',
            'November 21, 2022'
          ],
          'correctIndex': 1
        },
        {
          'question':
              'How long do the luminescent spots on the orchid glow after sunset?',
          'options': ['4-6 hours', '7-9 hours', '10-12 hours', '14-16 hours'],
          'correctIndex': 1
        },
        {
          'question': 'How far was the base camp from the nearest village?',
          'options': [
            '23 kilometers',
            '37 kilometers',
            '45 kilometers',
            '59 kilometers'
          ],
          'correctIndex': 1
        },
        {
          'question':
              'What percentage did the team exceed their initial data collection goal by?',
          'options': ['24%', '37%', '45%', '56%'],
          'correctIndex': 1
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    // Initialize with empty list since no story is selected yet
    _questionResults = [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _selectStory(int index) {
    setState(() {
      _selectedStoryIndex = index;
      _readingStory = true;
      _showQuestions = false;
      _currentQuestionIndex = 0;
      _score = 0;
      // Initialize question results with the correct length for the selected story
      _questionResults = List.filled(_stories[index]['questions'].length, null);
    });
  }

  void _startQuestions() {
    setState(() {
      _readingStory = false;
      _showQuestions = true;
      _remainingQuestionTime = 30; // Reset timer for new question
    });
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingQuestionTime > 0) {
          _remainingQuestionTime--;
        } else {
          // Time's up - move to next question
          _questionTimer?.cancel();

          // Record as incorrect answer if time runs out
          if (_questionResults[_currentQuestionIndex] == null) {
            _questionResults[_currentQuestionIndex] = false;
          }

          // Move to next question or results
          if (_currentQuestionIndex <
              _stories[_selectedStoryIndex]['questions'].length - 1) {
            _currentQuestionIndex++;
            _remainingQuestionTime = 30; // Reset timer
            _startQuestionTimer(); // Start timer for new question
          } else {
            // All questions answered or timed out
            _tabController.animateTo(1); // Switch to results tab
            _questionTimer?.cancel();
          }
        }
      });
    });
  }

  void _checkAnswer(int selectedOptionIndex) {
    final questions = _stories[_selectedStoryIndex]['questions'];
    final correctIndex = questions[_currentQuestionIndex]['correctIndex'];

    setState(() {
      _questionResults[_currentQuestionIndex] =
          selectedOptionIndex == correctIndex;
      if (selectedOptionIndex == correctIndex) {
        _score++;
      }
    });

    // Wait a moment to show feedback before moving to next question
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _questionTimer?.cancel(); // Cancel current timer

        if (_currentQuestionIndex < questions.length - 1) {
          _currentQuestionIndex++;
          _remainingQuestionTime = 30; // Reset timer for new question
          _startQuestionTimer(); // Start timer for new question
        } else {
          // All questions answered
          _tabController.animateTo(1); // Switch to results tab
        }
      });
    });
  }

  void _resetActivity() {
    setState(() {
      _selectedStoryIndex = -1;
      _readingStory = false;
      _showQuestions = false;
      _currentQuestionIndex = 0;
      _questionTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _selectedStoryIndex == -1
              ? "Story Recall"
              : _readingStory
                  ? "Reading Time"
                  : _showQuestions
                      ? "Story Questions"
                      : "Results",
          style: TextStyle(
            color: Color(0xFF0D3445),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
          onPressed: () {
            if (_selectedStoryIndex == -1) {
              Navigator.pop(context);
            } else {
              _resetActivity();
            }
          },
        ),
        bottom: _selectedStoryIndex != -1 && !_readingStory && !_showQuestions
            ? TabBar(
                controller: _tabController,
                labelColor: Color(0xFF0D3445),
                tabs: [
                  Tab(text: "Questions"),
                  Tab(text: "Results"),
                ],
              )
            : null,
      ),
      body: _selectedStoryIndex == -1
          ? _buildStoryListView()
          : _readingStory
              ? _buildReadingView()
              : _showQuestions
                  ? _buildQuestionsView()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildQuestionsReviewView(),
                        _buildResultsView(),
                      ],
                    ),
    );
  }

  Widget _buildStoryListView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFF0D3445)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => _selectStory(index),
              child: Container(
                height: 120, // Fixed height for all story items
                decoration: BoxDecoration(
                  color: Color(0xFF0D3445),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Image.asset(
                        story['coverImage'],
                        width: 100,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              story['author'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  story['duration'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(
                                  Icons.question_answer,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "${story['questions'].length} questions",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      height: 120, // Match container height
                      width: 44,
                      decoration: BoxDecoration(
                        color: Color(0xFF4E6077),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadingView() {
    final story = _stories[_selectedStoryIndex];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Color(0xFF0D3445).withAlpha(77)
          ], // 0.3 opacity = 77 alpha
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _startQuestions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D3445),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text("Start Questions"),
              ),
            ),
          ),
          // Story content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['title'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3445),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "by ${story['author']}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0D3445).withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    story['text'],
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      color: Color(0xFF0D3445),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsView() {
    final story = _stories[_selectedStoryIndex];
    final questions = story['questions'] as List;
    final currentQuestion =
        questions[_currentQuestionIndex] as Map<String, dynamic>;
    final options = currentQuestion['options'] as List;
    final correctIndex = currentQuestion['correctIndex'] as int;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFF0D3445).withAlpha(77)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timer bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _remainingQuestionTime / 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _remainingQuestionTime > 10
                            ? Color(0xFF0D3445)
                            : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "$_remainingQuestionTime s",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _remainingQuestionTime > 10
                      ? Color(0xFF0D3445)
                      : Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Progress indicator
          Row(
            children: List.generate(
              questions.length,
              (index) => Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _currentQuestionIndex >= index
                        ? Color(0xFF0D3445)
                        : Color(0xFF0D3445).withAlpha(77), // Fix opacity
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24),

          // Question number
          Text(
            "QUESTION ${_currentQuestionIndex + 1} OF ${questions.length}",
            style: TextStyle(
              color: Color(0xFF0D3445),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),

          // Question
          Text(
            currentQuestion['question']?.toString() ?? 'Question',
            style: TextStyle(
              color: Color(0xFF0D3445),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          SizedBox(height: 24),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index]?.toString() ?? '';
                bool isCorrectOption = index == correctIndex;
                bool isAnswered =
                    _questionResults[_currentQuestionIndex] != null;
                bool userSelectedThisOption = false; // We'll set this if needed

                // Determine the container color based on various states
                Color containerColor = Color(0xFF0D3445); // Default color

                if (isAnswered) {
                  if (isCorrectOption) {
                    // Always show correct option in green once answered
                    containerColor = Colors.green;
                  } else if (_questionResults[_currentQuestionIndex] == false &&
                      userSelectedThisOption) {
                    // Show incorrect selected option in red
                    containerColor = Colors.red;
                  }
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: isAnswered ? null : () => _checkAnswer(index),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: containerColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsReviewView() {
    if (_selectedStoryIndex < 0) {
      return Center(child: Text("No story selected"));
    }

    final story = _stories[_selectedStoryIndex];
    final questions = story['questions'];

    return Container(
      padding: EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final options = question['options'];
          final correctIndex = question['correctIndex'];
          final isAnsweredCorrectly = _questionResults[index] ?? false;

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isAnsweredCorrectly ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${index + 1}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D3445),
                        ),
                      ),
                      Icon(
                        isAnsweredCorrectly ? Icons.check_circle : Icons.cancel,
                        color: isAnsweredCorrectly ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    question['question'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3445),
                    ),
                  ),
                  SizedBox(height: 12),
                  ...options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isCorrect = index == correctIndex;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? Colors.green.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCorrect ? Colors.green : Colors.grey,
                          ),
                        ),
                        child: Row(
                          children: [
                            isCorrect
                                ? Icon(Icons.check_circle,
                                    color: Colors.green, size: 20)
                                : Icon(Icons.circle_outlined,
                                    color: Colors.grey, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  color:
                                      isCorrect ? Colors.green : Colors.black,
                                  fontWeight: isCorrect
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsView() {
    if (_selectedStoryIndex < 0) {
      return Center(child: Text("No story selected"));
    }

    final story = _stories[_selectedStoryIndex];
    final questions = story['questions'];
    final percentage = _score / questions.length * 100;

    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Score display
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0D3445),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${percentage.toInt()}%",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Score",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32),

          // Results summary
          Text(
            _score == questions.length
                ? "Perfect Score! Amazing memory!"
                : _score >= questions.length * 0.8
                    ? "Great job! Your memory is impressive!"
                    : _score >= questions.length * 0.6
                        ? "Good effort! Keep practicing!"
                        : "Keep trying to improve your memory!",
            style: TextStyle(
              color: Color(0xFF0D3445),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "You correctly answered $_score out of ${questions.length} questions",
            style: TextStyle(
              color: Color(0xFF0D3445).withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(0);
                },
                icon: Icon(Icons.refresh),
                label: Text("Review Questions"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D3445),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _resetActivity,
                icon: Icon(Icons.home),
                label: Text("New Story"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0D3445),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Add this method for more graceful error handling
  void _handleError(String message) {
    // Show a snackbar or dialog with the error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    // Reset to a safe state
    _resetActivity();
  }
}
