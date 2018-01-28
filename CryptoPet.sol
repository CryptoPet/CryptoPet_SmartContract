pragma solidity ^0.4.4;

import "eth-random/contracts/Random.sol";

contract HiDog {
    Random api = Random(/* set address here */);

  //  enum nature {fire,warter,thunder}
    
    enum state{egg,born,complete,evolution}
    
  //  enum color {red,blue,yellow }
    // enum texture {t1, t2,t3 }
    enum generation{g1,g2,g3,g4,g5}
    struct Dog {
        uint dId;
        string nature;
        string state;
        string color;
        string texture;
        string gen;
        uint level;
        uint needNextexp;
        address _owner;
        int16  hp;
    }
    string[] nature = ["fire","warter","thunder"];
    string[] color =["red","blue","yellow"];
    string[] texture =["t1","t2","t3"];
        //约定所需经验值计算公式：1000+(1+30%)*(level-1)
        //攻击力公式：(level-1)*0.15*100+100;
        //血量公式：(level-1)*(0.5)*100+200
        //战斗获得经验公式:
        //如果等级相同:100+level*0.1*20
        //如果以低级战胜高级：100+level*0.1*20+(levelOther-level)*20
        //如果高级赢低级：100+level*0.1*20-(level-levelOther)*20
        //战斗失败：100
    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }
    address public dog;
    mapping(address => Dog) public dog;

    function finalFight(uint exp) {
        if (dog.needNextexp <= exp) {
            dog.level++;
            dog.needNextexp = 1000+(1+0.3)*(dog.level-1);
        }else {
            dog.needNextexp=dog.needNextexp-exp;
        }
    }


    function fightWithOther(address other){
        uint att = (dog.level-1)*0.15*100+100;
        uint levelOther = other.level;
        uint attOther = other.att;
        uint hpOther=other.hp;
        startFight( att, levelOther, attOther, hpOther);
    }
    function startmission(){
        uint att = (dog.level-1)*0.15*100+100;
        uint levelOther = dog.level-3+api.random(5);
        uint attOther = (levelOther-1)*0.15*100+100;
        uint hpOther=dog.hp+random(5);
        startFight( att, levelOther, attOther, hpOther);
    }
    //战斗判断逻辑
    function startFight(uint att,uint levelOther,uint attOther,uint hpOther){
        myFirst = false;
        if(hpOther%2 == 0)
            myFirst = true;
        
        if (myFirst == true) {
             while (dog.hp > 0 && hpOther > 0){
                if ((hpOther-=att)<=0||(dog.hp-=attOther)<=0) break;
             }
             
             
        } else {
            while (dog.hp > 0 && hpOther > 0){
                if ((dog.hp-=attOther)<=0||(hpOther-=att)<=0)
                    break;
             }
        }
        uint getExp=0;
        if (dog.hp<=0) {
            getExp=100;
        } else {
            if (dog.level==levelOther) 
                getExp=100+dog.level*0.1*20;
            if (dog.level > levelOther) 
                getExp = 100+dog.level*0.1*20-(dog.level-levelOther)*20;
            if (dog.level < levelOther)  
                getExp=100+dog.level*0.1*20+(levelOther-dog.level)*20;
        } 
        attOther=0;
        att=0;
        uint8 exp = api.random(6);
        dog.finalFight(exp);
    }
    
    function exchangeOwner(address newOwner){
        dog._owner=newOwner;
    }
    //创建dog
    function _createDog(
        string _nature,
        string _state, 
        string _color,
        string _texture, 
        string _gen, 
        uint _level, 
        uint _needNextexp, 
        address _owner,
        int16  _hp 
    )
        internal
        returns (uint)
    {
         Dog memory _dog = Dog({
            nature:_nature,
            state:_state,
            color:_color,
            texture:_texture,
            gen:_gen,
            level:_level,
            needNextexp:_needNextexp,
            owner:_owner,
            hp:_hp
        });
        uint256 nid = keccak256(_nature,_state,_color,_texture,now);

        return nid;
    }

    function makeBaby(address other) did returns(uint){
        string _nature = other.nature;
        string _color = other.color;
        string _texture = other.texture;
        string _gen = other.gen;
        address _owner = other._owner;

        api = Random(other);
        nature=[_nature,dog.nature];
        color=[_color,dog.color];
        texture=[_texture,dog.texture];

        Dog memory _dog = Dog({
            nature:nature[api.random(2)],
            state:state.egg,
            color:color[api.random(2)],
            texture:texture[api.random(2)],
            gen:dog.gen>_gen?dog.gen+1:_gen+1,
            level:0,
            needNextexp:1000,
            owner:dog.owner,
            hp:100
        });

        return keccak256(_dog.nature,_dog.state,_dog.color,_dog.texture,now);
    }
}
