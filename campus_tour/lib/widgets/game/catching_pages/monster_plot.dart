import 'package:campus_tour/widgets/game/catching_pages/plot_level.dart';

/// 每個精靈的專屬 battle 劇情台詞。
/// Key 為 monster.id（對應 Firestore 的文件 ID）。
/// 若某個精靈沒有設定，BuildingMonsterLevel 會自動 fallback 到 DefaultPlot。
class MonsterPlot {
  MonsterPlot._();

  /// 回傳指定精靈的 battlePlotDialogueSteps。
  /// [monsterId]   monster.id
  /// [fairyImagePath] monster.imageURL，用於 center sprite
  static List<PlotDialogueStep>? battleSteps({
    required String monsterId,
    required String fairyImagePath,
  }) {
    final builder = _plots[monsterId];
    if (builder == null) return null;
    return builder(fairyImagePath);
  }

  // ── 資料表 ──────────────────────────────────────────────────────────────
  // 格式：'monster_id': (imageUrl) => [PlotDialogueStep, ...]
  //
  // 台詞設計原則：
  //   • 精靈「直接現身」，第一句就是牠的個性台詞
  //   • 2～4 步即可，不要拖太長
  //   • speakerSlot.center 搭配 centerSpritePath 可讓精靈圖出現在舞台中央
  // ────────────────────────────────────────────────────────────────────────

  static final Map<String, List<PlotDialogueStep> Function(String)> _plots = {

    // 中大湖
    'm1': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '中大湖水怪',
        text: '呼——終於有人來了！我在這個湖裡待了好幾十年，無聊死了！',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（湖面冒出個東西……牠看起來比我還興奮？）',
      ),
    ],

    // 客家學院
    'm2': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '客家狗',
        text: '汪！你會說客家話嗎？不會？那你來這裡幹嘛！',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠好像用客家話罵了我什麼……但我完全聽不懂。））',
      ),
    ],

    // 地球科學學院
    'm3': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '小蛋球',
        text: '我見過板塊漂移、見過火山爆發，你算什麼？嗯……還挺小的。',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠說我小？牠自己也不大啊。）',
      ),
    ],

    // 大象五形
    'm4': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '大大象',
        text: '金！木！水！火！土！你猜我是哪一形？猜對了再說話！',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠跺腳的聲音好大……我還是先猜吧。）',
      ),
    ],

    // 太極銅雕
    'm5': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '小拳極',
        text: '借力使力，不跟你硬碰硬喔！所以你最好也別硬來！',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠擺出一個架勢……感覺隨時會飛出去。）',
      ),
    ],

    // 工學院
    'm6': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '機居械',
        text: '橋是我蓋的、機器是我修的，你有什麼本事，說來聽聽？',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（齒輪轉動聲從牠身體裡傳出來……有點酷。）',
      ),
    ],

    // 文學院
    'm7': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '讀書怪',
        text: '噓——這裡在看書！你進來之前有沒有先把手洗乾淨！',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠抱著一疊書瞪著我……我感覺自己做錯了什麼。）',
      ),
    ],

    // 友好之櫻
    'm8': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '嚶嚶嚶',
        text: '嚶～這朵花是日本帶來的耶，你有沒有好好珍惜它啊？嚶～',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（花瓣飄落在我頭上……牠好像快哭了？）',
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.left,
        speakerName: '嚶嚶嚶',
        text: '嚶嚶嚶……你要陪我待久一點嘛，每次大家來都走得好快……',
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠抱住我的腳不放……這傢伙，還挺難纏的。）',
      ),
    ],

    // 永續與綠能科技研究學院
    'm9': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '環寶寶',
        text: '2050年淨零！你有在做垃圾分類嗎？回答我！',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠的眼神太認真了……我突然有點心虛。）',
      ),
    ],

    // 理學院
    'm10': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '數碼博士',
        text: '量子！粒子！星系！你跟得上嗎？跟不上也沒關係，我說慢一點。',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠已經開始在空中寫算式了……）',
      ),
    ],

    // 生醫理工學院
    'm11': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '大英菌',
        text: '哈囉～我是你身體裡也有的東西的親戚，不用緊張，我是好的那種！',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠笑得很燦爛……但我還是往後退了一步。）',
      ),
    ],

    // 百花川
    'm12': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '毛毛精靈',
        text: '這條路我走了好幾年，你第一次來吧？我帶你逛！',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠已經開始在前面帶路了，等我一下啊。）',
      ),
    ],

    // 管院
    'm13': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: 'SM獸',
        text: '簡報、數字、會議、再簡報……你要不要幫我做一點？',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠的黑眼圈好深……我感覺到一股壓力。）',
      ),
    ],

    // 資訊電機學院
    'm14': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '亮晶精',
        text: '偵測到新目標！正在分析中……嗯，勉強及格，可以互動。',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠用掃描的眼神看著我……有點毛。）',
      ),
    ],
  
    // DNA交響曲
    'm15': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: 'DNA 交響曲',
        text: '螺旋！上升！光影！交錯！我的表演你看懂了嗎？',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠在原地轉了好幾圈……好像很享受。）',
      ),
    ],

    // Cycle-90° 羽翼
    'm16': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '羽翼',
        text: '風來我就轉，沒風我就等。你有這種耐心嗎？',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠說完就靜止不動了……在等風嗎？還是在等我？）',
      ),
    ],

    // 坐雲飛想
    'm17': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '坐雲飛想',
        text: '雲朵不趕路，松果慢慢長。你今天發過呆了沒？',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠看起來剛睡醒。）',
      ),
    ],

    // 坐聽‧松風
    'm18': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '坐聽・松風',
        text: '噓……你聽，有沒有聽到風？沒有？那你再安靜一點。',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（我們就這樣沉默了五秒……牠好像很滿意。）',
      ),
    ],

    // 為什麼
    'm19': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '為什麼',
        text: '為什麼天是藍的？為什麼風會動？為什麼你今天來這裡？',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠的問題一個接一個……我突然不知道怎麼回答。）',
      ),
    ],

    // 漫步雲端
    'm20': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '漫步雲端',
        text: '欸，你躺下來看過這片天空嗎？不躺不算來過喔！',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠已經躺下去了……好吧，我也試試。）',
      ),
    ],

    // 蘊˙行
    'm21': (img) => [
      PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.center,
        speakerName: '蘊・行',
        text: '風吹過來，我就動一下。不急，反正你也跑不掉。',
        centerSpritePath: img,
      ),
      const PlotDialogueStep(
        speakerSlot: PlotSpeakerSlot.right,
        speakerName: '我',
        text: '（牠說話慢條斯理的……但哪裡好像怪怪的。）',
      ),
    ],
  };
}